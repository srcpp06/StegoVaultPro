import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StegoResult {
  final bool success;
  final String message;
  final String? outputPath;

  StegoResult({required this.success, required this.message, this.outputPath});
}

class StegoUtils {
  static const String trailMagic = 'STEGO_TR';
  static const String trailEnd   = 'STEGO_EN';

  static Uint8List deriveKey(String password) {
    final digest = sha256.convert(utf8.encode(password));
    return Uint8List.fromList(digest.bytes);
  }

  static Uint8List xorCrypt(Uint8List data, Uint8List key) {
    final out = Uint8List(data.length);
    for (int i = 0; i < data.length; i++) {
      out[i] = data[i] ^ key[i % key.length];
    }
    return out;
  }

  // Build payload to append to any carrier file
  static Uint8List buildPayload({
    required String fileName,
    required Uint8List fileData,
    String? password,
  }) {
    final hasPassword = password != null && password.isNotEmpty;
    Uint8List data = fileData;
    if (hasPassword) {
      data = xorCrypt(fileData, deriveKey(password));
    }

    final fileNameBytes = utf8.encode(fileName);
    final bb = BytesBuilder();
    bb.add(utf8.encode(trailMagic));
    bb.addByte(hasPassword ? 1 : 0);
    bb.addByte(fileNameBytes.length >> 8);
    bb.addByte(fileNameBytes.length & 0xFF);
    bb.add(fileNameBytes);
    bb.addByte((data.length >> 24) & 0xFF);
    bb.addByte((data.length >> 16) & 0xFF);
    bb.addByte((data.length >> 8)  & 0xFF);
    bb.addByte( data.length        & 0xFF);
    bb.add(data);
    bb.add(utf8.encode(trailEnd));
    return bb.toBytes();
  }

  static Future<StegoResult> extractPayload({
    required Uint8List carrierBytes,
    required String outputDir,
    String? password,
  }) async {
    if (carrierBytes.length < 30) {
      return StegoResult(success: false, message: 'Faylda yashirilgan ma\'lumot topilmadi');
    }

    final endMarker = utf8.encode(trailEnd);
    int endPos = -1;
    outer:
    for (int i = carrierBytes.length - 8; i >= 0; i--) {
      for (int j = 0; j < 8; j++) {
        if (carrierBytes[i + j] != endMarker[j]) continue outer;
      }
      endPos = i;
      break;
    }
    if (endPos < 0) {
      return StegoResult(success: false, message: 'Bu faylda yashirilgan ma\'lumot topilmadi');
    }

    final startMarker = utf8.encode(trailMagic);
    int startPos = -1;
    outer2:
    for (int i = endPos - 8; i >= 0; i--) {
      for (int j = 0; j < 8; j++) {
        if (carrierBytes[i + j] != startMarker[j]) continue outer2;
      }
      startPos = i;
      break;
    }
    if (startPos < 0) {
      return StegoResult(success: false, message: 'Yashirilgan ma\'lumot topilmadi yoki buzilgan');
    }

    int offset = startPos + 8;
    final hasPassword = carrierBytes[offset++] == 1;
    final fileNameLen = (carrierBytes[offset] << 8) | carrierBytes[offset + 1];
    offset += 2;
    final fileName = utf8.decode(carrierBytes.sublist(offset, offset + fileNameLen));
    offset += fileNameLen;
    final dataLen = (carrierBytes[offset] << 24) |
        (carrierBytes[offset + 1] << 16) |
        (carrierBytes[offset + 2] << 8) |
        carrierBytes[offset + 3];
    offset += 4;

    if (hasPassword && (password == null || password.isEmpty)) {
      return StegoResult(success: false, message: 'PAROL_KERAK');
    }

    Uint8List fileData = carrierBytes.sublist(offset, offset + dataLen);
    if (hasPassword) {
      fileData = xorCrypt(fileData, deriveKey(password!));
    }

    final outPath = p.join(outputDir, fileName);
    await File(outPath).writeAsBytes(fileData);
    return StegoResult(
      success: true,
      message: 'Fayl muvaffaqiyatli chiqarildi!',
      outputPath: outPath,
    );
  }

  static bool hasTrailContent(Uint8List bytes) {
    if (bytes.length < 16) return false;
    final endMarker = utf8.encode(trailEnd);
    for (int i = bytes.length - 8; i >= 0; i--) {
      bool match = true;
      for (int j = 0; j < 8; j++) {
        if (bytes[i + j] != endMarker[j]) { match = false; break; }
      }
      if (match) return true;
    }
    return false;
  }

  // ── Cross-platform output directory ──────────────────────────────────────
  // Android: getExternalStorageDirectory (SDCard/Downloads)
  // iOS: getApplicationDocumentsDirectory (Files app görünür)
  // Linux/Windows/macOS: ~/Downloads
  static Future<Directory> getOutputDir() async {
    try {
      if (Platform.isAndroid) {
        // Try external storage first (visible in file manager)
        final external = await getExternalStorageDirectory();
        if (external != null) {
          // Go up to root of external storage, then into Download
          final parts = external.path.split('/');
          final androidIdx = parts.indexOf('Android');
          if (androidIdx > 0) {
            final rootPath = parts.sublist(0, androidIdx).join('/');
            final downloads = Directory('$rootPath/Download');
            if (!downloads.existsSync()) {
              await downloads.create(recursive: true);
            }
            return downloads;
          }
          return external;
        }
        // Fallback: app documents
        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        // iOS: Documents directory (visible in Files app)
        final docs = await getApplicationDocumentsDirectory();
        return docs;
      } else {
        // Desktop (Linux, macOS, Windows)
        final home = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ?? '';
        if (home.isNotEmpty) {
          for (final candidate in ['Downloads', 'Desktop', 'Documents']) {
            final dir = Directory(p.join(home, candidate));
            if (dir.existsSync()) return dir;
          }
        }
        return await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      return await getApplicationDocumentsDirectory();
    }
  }

  // Human-readable output location description
  static String outputDirLabel(String outPath) {
    if (Platform.isAndroid) return 'Telefon xotirasi/Download';
    if (Platform.isIOS) return 'Fayllar ilovasi/Steganography';
    return outPath;
  }
}
