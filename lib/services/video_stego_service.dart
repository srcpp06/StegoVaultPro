import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'stego_utils.dart';

class VideoStegoService {
  static Future<StegoResult> hideFile({
    required String videoPath,
    required String filePath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final videoBytes = await File(videoPath).readAsBytes();
      final fileBytes = Uint8List.fromList(await File(filePath).readAsBytes());
      final fileName = p.basename(filePath);
      final videoName = p.basename(videoPath);

      final payload = StegoUtils.buildPayload(
        fileName: fileName,
        fileData: fileBytes,
        password: password,
      );

      final combined = Uint8List(videoBytes.length + payload.length);
      combined.setAll(0, videoBytes);
      combined.setAll(videoBytes.length, payload);

      final outPath = p.join(outputDir, videoName);
      await File(outPath).writeAsBytes(combined);

      return StegoResult(
        success: true,
        message: 'Fayl video ichiga yashirildi!\nVideo fayl odatdagidek ijro etiladi.',
        outputPath: outPath,
      );
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  static Future<StegoResult> unhideFile({
    required String videoPath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final bytes = await File(videoPath).readAsBytes();
      return await StegoUtils.extractPayload(
        carrierBytes: bytes,
        outputDir: outputDir,
        password: password,
      );
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  static Future<bool> hasHiddenContent(String videoPath) async {
    try {
      final bytes = await File(videoPath).readAsBytes();
      return StegoUtils.hasTrailContent(bytes);
    } catch (_) {
      return false;
    }
  }
}
