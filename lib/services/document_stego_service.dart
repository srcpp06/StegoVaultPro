import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'stego_utils.dart';

class DocumentStegoService {
  static Future<StegoResult> hideFile({
    required String docPath,
    required String filePath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final docBytes = await File(docPath).readAsBytes();
      final fileBytes = Uint8List.fromList(await File(filePath).readAsBytes());
      final fileName = p.basename(filePath);
      final docName = p.basename(docPath);

      final payload = StegoUtils.buildPayload(
        fileName: fileName,
        fileData: fileBytes,
        password: password,
      );

      final combined = Uint8List(docBytes.length + payload.length);
      combined.setAll(0, docBytes);
      combined.setAll(docBytes.length, payload);

      final outPath = p.join(outputDir, docName);
      await File(outPath).writeAsBytes(combined);

      return StegoResult(
        success: true,
        message: 'Fayl hujjat ichiga yashirildi!\nHujjat odatdagidek ochiladi.',
        outputPath: outPath,
      );
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  static Future<StegoResult> unhideFile({
    required String docPath,
    required String outputDir,
    String? password,
  }) async {
    try {
      final bytes = await File(docPath).readAsBytes();
      return await StegoUtils.extractPayload(
        carrierBytes: bytes,
        outputDir: outputDir,
        password: password,
      );
    } catch (e) {
      return StegoResult(success: false, message: 'Xato: $e');
    }
  }

  static Future<bool> hasHiddenContent(String docPath) async {
    try {
      final bytes = await File(docPath).readAsBytes();
      return StegoUtils.hasTrailContent(bytes);
    } catch (_) {
      return false;
    }
  }
}
