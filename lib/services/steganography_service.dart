import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as pathLib;
import 'stego_utils.dart';

export 'stego_utils.dart' show StegoResult;

/// Image steganography using LSB (Least Significant Bit) method.
/// IMPORTANT: Output is ALWAYS saved as PNG to preserve LSB data.
/// The hidden data format is cross-platform compatible.
class SteganographyService {
  // Magic: 8 bytes, uniquely identifies this format
  static const String _magic = 'STEGO_V1';

  static List<int> _bytesToBits(Uint8List bytes) {
    final bits = <int>[];
    for (final b in bytes) {
      for (int i = 7; i >= 0; i--) bits.add((b >> i) & 1);
    }
    return bits;
  }

  static Uint8List _bitsToBytes(List<int> bits) {
    final out = <int>[];
    for (int i = 0; i < bits.length; i += 8) {
      int b = 0;
      for (int j = 0; j < 8 && i + j < bits.length; j++) {
        b = (b << 1) | bits[i + j];
      }
      out.add(b);
    }
    return Uint8List.fromList(out);
  }

  // Embed bits into image pixels - uses R,G,B channels LSB
  // Pixel order: left-to-right, top-to-bottom (deterministic, same on all platforms)
  static img.Image _embedBits(img.Image src, List<int> bits) {
    // Always work on RGBA8 format for consistency
    final image = src.convert(format: img.Format.uint8, numChannels: 4);
    int idx = 0;
    outer:
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if (idx >= bits.length) break outer;
        final px = image.getPixel(x, y);
        int r = px.r.toInt();
        int g = px.g.toInt();
        int b = px.b.toInt();
        final a = px.a.toInt();

        if (idx < bits.length) r = (r & 0xFE) | bits[idx++];
        if (idx < bits.length) g = (g & 0xFE) | bits[idx++];
        if (idx < bits.length) b = (b & 0xFE) | bits[idx++];

        image.setPixel(x, y, img.ColorRgba8(r, g, b, a));
      }
    }
    return image;
  }

  static List<int> _extractBits(img.Image src, int count) {
    final image = src.convert(format: img.Format.uint8, numChannels: 4);
    final bits = <int>[];
    outer:
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if (bits.length >= count) break outer;
        final px = image.getPixel(x, y);
        final r = px.r.toInt();
        final g = px.g.toInt();
        final b = px.b.toInt();
        if (bits.length < count) bits.add(r & 1);
        if (bits.length < count) bits.add(g & 1);
        if (bits.length < count) bits.add(b & 1);
      }
    }
    return bits;
  }

  // Build payload bytes
  static Uint8List _buildPayload(String fileName, Uint8List fileData, String? password) {
    final hasPassword = password != null && password.isNotEmpty;
    Uint8List data = fileData;
    if (hasPassword) {
      data = StegoUtils.xorCrypt(fileData, StegoUtils.deriveKey(password!));
    }
    final fileNameBytes = utf8.encode(fileName);
    final bb = BytesBuilder();
    bb.add(utf8.encode(_magic));                   // 8 bytes
    bb.addByte(hasPassword ? 1 : 0);               // 1 byte
    bb.addByte(fileNameBytes.length >> 8);          // 2 bytes
    bb.addByte(fileNameBytes.length & 0xFF);
    bb.add(fileNameBytes);                          // N bytes
    bb.addByte((data.length >> 24) & 0xFF);         // 4 bytes
    bb.addByte((data.length >> 16) & 0xFF);
    bb.addByte((data.length >> 8)  & 0xFF);
    bb.addByte( data.length        & 0xFF);
    bb.add(data);                                   // data
    return bb.toBytes();
  }

  /// Hide a file inside an image.
  /// Output is ALWAYS PNG (to preserve LSB data losslessly).
  /// Output filename = original image name with .png extension.
  static Future<StegoResult> hideFile({
    required String imagePath,
    required String filePath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return StegoResult(success: false, message: 'Rasm faylini o\'qib bo\'lmadi');
      }

      final fileBytes = Uint8List.fromList(await File(filePath).readAsBytes());
      final fileName = pathLib.basename(filePath);

      final payload = _buildPayload(fileName, fileBytes, password);
      final bits = _bytesToBits(payload);

      // 3 bits per pixel (R+G+B LSB)
      final capacity = image.width * image.height * 3;
      if (bits.length > capacity) {
        final needKB = (bits.length / 8 / 1024).toStringAsFixed(1);
        final haveKB = (capacity / 8 / 1024).toStringAsFixed(1);
        return StegoResult(
          success: false,
          message: 'Rasm juda kichik!\nKerak: $needKB KB, Mavjud: $haveKB KB\n'
              'Kattaroq rasm tanlang.',
        );
      }

      final outputImage = _embedBits(image, bits);

      // CRITICAL: always save as PNG (lossless) regardless of input format
      // Change extension to .png to avoid confusion
      final baseName = pathLib.basenameWithoutExtension(
          pathLib.basename(imagePath));
      final outputFileName = '${baseName}_stego.png';
      final outputPath = pathLib.join(outputDir, outputFileName);

      final pngBytes = img.encodePng(outputImage);
      await File(outputPath).writeAsBytes(pngBytes);

      return StegoResult(
        success: true,
        message: 'Fayl muvaffaqiyatli yashirildi!\n'
            '⚠ Natija PNG formatida saqlandi.\n'
            'Bu faylni boshqa qurilmada unhide qilish mumkin.',
        outputPath: outputPath,
      );
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  /// Extract hidden file from image.
  static Future<StegoResult> unhideFile({
    required String imagePath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return StegoResult(success: false, message: 'Rasm faylini o\'qib bo\'lmadi');
      }

      // Step 1: read header (11 bytes = 88 bits)
      const hdrBytes = 11;
      final hdrBits = _extractBits(image, hdrBytes * 8);
      final hdr = _bitsToBytes(hdrBits);

      final magic = utf8.decode(hdr.sublist(0, 8), allowMalformed: true);
      if (magic != _magic) {
        return StegoResult(
          success: false,
          message: 'Bu rasmda yashirilgan fayl topilmadi.\n'
              'Faqat ushbu ilova bilan yashirilgan rasmlar ishlatilishi mumkin.',
        );
      }

      final hasPassword = hdr[8] == 1;
      final fnLen = (hdr[9] << 8) | hdr[10];

      if (hasPassword && (password == null || password.isEmpty)) {
        return StegoResult(success: false, message: 'PAROL_KERAK');
      }

      // Step 2: read filename + data length
      final step2Bytes = hdrBytes + fnLen + 4;
      final step2Bits = _extractBits(image, step2Bytes * 8);
      final step2 = _bitsToBytes(step2Bits);

      final fileName = utf8.decode(step2.sublist(hdrBytes, hdrBytes + fnLen));
      final off = hdrBytes + fnLen;
      final dataLen = (step2[off] << 24) | (step2[off+1] << 16) |
                      (step2[off+2] << 8)  | step2[off+3];

      if (dataLen <= 0 || dataLen > image.width * image.height * 3 ~/ 8) {
        return StegoResult(success: false,
            message: 'Fayl buzilgan yoki noto\'g\'ri format');
      }

      // Step 3: read all data
      final totalBytes = step2Bytes + dataLen;
      final allBits = _extractBits(image, totalBytes * 8);
      final allData = _bitsToBytes(allBits);

      Uint8List fileData = allData.sublist(step2Bytes);

      if (hasPassword) {
        fileData = StegoUtils.xorCrypt(fileData, StegoUtils.deriveKey(password!));
      }

      final outPath = pathLib.join(outputDir, fileName);
      await File(outPath).writeAsBytes(fileData);

      return StegoResult(
        success: true,
        message: 'Fayl muvaffaqiyatli chiqarildi!',
        outputPath: outPath,
      );
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  static Future<bool> hasHiddenContent(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return false;
      final bits = _extractBits(image, 64);
      final bytes = _bitsToBytes(bits);
      return utf8.decode(bytes, allowMalformed: true) == _magic;
    } catch (_) {
      return false;
    }
  }
}
