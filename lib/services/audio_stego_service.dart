import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'stego_utils.dart';

class AudioStegoService {
  static const String _wavMagic = 'STEGO_WA'; // WAV LSB marker

  // ── WAV LSB helpers ──────────────────────────────────────────────────────

  static List<int> _bytesToBits(Uint8List bytes) {
    final bits = <int>[];
    for (final b in bytes) {
      for (int i = 7; i >= 0; i--) bits.add((b >> i) & 1);
    }
    return bits;
  }

  static Uint8List _bitsToBytes(List<int> bits) {
    final bytes = <int>[];
    for (int i = 0; i < bits.length; i += 8) {
      int b = 0;
      for (int j = 0; j < 8 && (i + j) < bits.length; j++) {
        b = (b << 1) | bits[i + j];
      }
      bytes.add(b);
    }
    return Uint8List.fromList(bytes);
  }

  static bool _isWav(Uint8List bytes) {
    if (bytes.length < 12) return false;
    return String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WAVE';
  }

  // Find 'data' chunk offset in WAV
  static int _findWavDataOffset(Uint8List bytes) {
    int i = 12;
    while (i + 8 < bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(i, i + 4));
      final chunkSize = bytes.buffer.asByteData().getUint32(i + 4, Endian.little);
      if (chunkId == 'data') return i + 8;
      i += 8 + chunkSize;
    }
    return -1;
  }

  // Embed bits into WAV audio samples (each sample byte LSB = 1 bit)
  static Uint8List _embedInWav(Uint8List wav, List<int> bits) {
    final dataOffset = _findWavDataOffset(wav);
    if (dataOffset < 0) throw Exception('WAV data chunk topilmadi');

    final result = Uint8List.fromList(wav);
    int bitIdx = 0;
    for (int i = dataOffset; i < result.length && bitIdx < bits.length; i++) {
      result[i] = (result[i] & 0xFE) | bits[bitIdx++];
    }
    return result;
  }

  // Extract bits from WAV audio samples
  static List<int> _extractFromWav(Uint8List wav, int count) {
    final dataOffset = _findWavDataOffset(wav);
    if (dataOffset < 0) throw Exception('WAV data chunk topilmadi');

    final bits = <int>[];
    for (int i = dataOffset; i < wav.length && bits.length < count; i++) {
      bits.add(wav[i] & 1);
    }
    return bits;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<StegoResult> hideFile({
    required String audioPath,
    required String filePath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final audioBytes = await File(audioPath).readAsBytes();
      final fileBytes = Uint8List.fromList(await File(filePath).readAsBytes());
      final fileName = p.basename(filePath);
      final audioName = p.basename(audioPath);

      if (_isWav(audioBytes)) {
        // ── WAV LSB method ──────────────────────────────────────────────
        final hasPassword = password != null && password.isNotEmpty;
        Uint8List data = fileBytes;
        if (hasPassword) {
          data = StegoUtils.xorCrypt(fileBytes, StegoUtils.deriveKey(password));
        }

        final fileNameBytes = utf8.encode(fileName);
        // Payload: magic(8)+flag(1)+fnLen(2)+fn+dataLen(4)+data
        final bb = BytesBuilder();
        bb.add(utf8.encode(_wavMagic));
        bb.addByte(hasPassword ? 1 : 0);
        bb.addByte(fileNameBytes.length >> 8);
        bb.addByte(fileNameBytes.length & 0xFF);
        bb.add(fileNameBytes);
        bb.addByte((data.length >> 24) & 0xFF);
        bb.addByte((data.length >> 16) & 0xFF);
        bb.addByte((data.length >> 8) & 0xFF);
        bb.addByte(data.length & 0xFF);
        bb.add(data);

        final payload = bb.toBytes();
        final bits = _bytesToBits(payload);

        final dataOffset = _findWavDataOffset(audioBytes);
        if (dataOffset < 0) {
          return StegoResult(success: false, message: 'WAV formati noto\'g\'ri');
        }
        final available = (audioBytes.length - dataOffset) * 1; // 1 bit per byte
        if (bits.length > available) {
          return StegoResult(
            success: false,
            message: 'Audio fayl juda kichik. Kerakli: ${(bits.length / 8 / 1024).toStringAsFixed(1)} KB, '
                'mavjud: ${(available / 8 / 1024).toStringAsFixed(1)} KB',
          );
        }

        final newWav = _embedInWav(audioBytes, bits);
        final outPath = p.join(outputDir, audioName);
        await File(outPath).writeAsBytes(newWav);

        return StegoResult(
          success: true,
          message: 'Fayl WAV audio ichiga LSB usulida yashirildi!',
          outputPath: outPath,
        );
      } else {
        // ── Append method for MP3/FLAC/OGG/AAC etc ─────────────────────
        final payload = StegoUtils.buildPayload(
          fileName: fileName,
          fileData: fileBytes,
          password: password,
        );
        final combined = Uint8List(audioBytes.length + payload.length);
        combined.setAll(0, audioBytes);
        combined.setAll(audioBytes.length, payload);

        final outPath = p.join(outputDir, audioName);
        await File(outPath).writeAsBytes(combined);
        return StegoResult(
          success: true,
          message: 'Fayl audio ichiga yashirildi!',
          outputPath: outPath,
        );
      }
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  static Future<StegoResult> unhideFile({
    required String audioPath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final bytes = await File(audioPath).readAsBytes();

      if (_isWav(bytes)) {
        // Try WAV LSB first
        const headerBits = 11 * 8;
        final headerBitList = _extractFromWav(bytes, headerBits);
        final headerData = _bitsToBytes(headerBitList);

        final magic = utf8.decode(headerData.sublist(0, 8), allowMalformed: true);
        if (magic == _wavMagic) {
          final hasPassword = headerData[8] == 1;
          final fnLen = (headerData[9] << 8) | headerData[10];

          if (hasPassword && (password == null || password.isEmpty)) {
            return StegoResult(success: false, message: 'PAROL_KERAK');
          }

          final totalHeaderBytes = 11 + fnLen + 4;
          final moreBits = _extractFromWav(bytes, totalHeaderBytes * 8);
          final moreData = _bitsToBytes(moreBits);

          final fileName = utf8.decode(moreData.sublist(11, 11 + fnLen));
          final off = 11 + fnLen;
          final dataLen = (moreData[off] << 24) | (moreData[off + 1] << 16) |
              (moreData[off + 2] << 8) | moreData[off + 3];

          final allBits = _extractFromWav(bytes, (totalHeaderBytes + dataLen) * 8);
          final allData = _bitsToBytes(allBits);

          Uint8List fileData = allData.sublist(totalHeaderBytes);
          if (hasPassword) {
            fileData = StegoUtils.xorCrypt(fileData, StegoUtils.deriveKey(password!));
          }

          final outPath = p.join(outputDir, fileName);
          await File(outPath).writeAsBytes(fileData);
          return StegoResult(
            success: true,
            message: 'Fayl muvaffaqiyatli chiqarildi! (WAV LSB usuli)',
            outputPath: outPath,
          );
        }
        // fallthrough to append check
      }

      // Try append method
      return await StegoUtils.extractPayload(
        carrierBytes: bytes,
        outputDir: outputDir,
        password: password,
      );
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  static Future<bool> hasHiddenContent(String audioPath) async {
    try {
      final bytes = await File(audioPath).readAsBytes();
      if (_isWav(bytes)) {
        const bits = 64;
        final headerBitList = _extractFromWav(bytes, bits);
        final headerData = _bitsToBytes(headerBitList);
        final magic = utf8.decode(headerData.sublist(0, 8), allowMalformed: true);
        if (magic == _wavMagic) return true;
      }
      return StegoUtils.hasTrailContent(bytes);
    } catch (_) {
      return false;
    }
  }

  static String getCapacityInfo(String? audioPath) {
    if (audioPath == null) return '';
    try {
      final file = File(audioPath);
      if (!file.existsSync()) return '';
      final size = file.lengthSync();
      final ext = p.extension(audioPath).toLowerCase();
      if (ext == '.wav') {
        final kb = (size / 8 / 1024).toStringAsFixed(0);
        return 'LSB sig\'im: ~$kb KB';
      }
      return 'Fayl hajmiga qarab sig\'im mavjud';
    } catch (_) {
      return '';
    }
  }
}
