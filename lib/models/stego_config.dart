import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/stego_utils.dart';
export '../services/stego_utils.dart' show StegoResult;

/// Configures a generic hide/unhide screen for any media type
class StegoConfig {
  final String categoryKey;      // 'audio' | 'video' | 'document'
  final String displayName;      // 'Audio', 'Video', 'Hujjat'
  final Color primaryColor;
  final IconData icon;

  // Cover file picker config
  final String coverFileLabel;
  final FileType coverFileType;
  final List<String>? coverFileExtensions;

  // Service callbacks
  final Future<StegoResult> Function({
    required String coverPath,
    required String filePath,
    required String outputDir,
    String? password,
  }) hideFile;

  final Future<StegoResult> Function({
    required String coverPath,
    required String outputDir,
    String? password,
  }) unhideFile;

  final Future<bool> Function(String coverPath) hasHiddenContent;

  // Capacity info helper (optional)
  final String Function(String? coverPath)? capacityInfo;

  const StegoConfig({
    required this.categoryKey,
    required this.displayName,
    required this.primaryColor,
    required this.icon,
    required this.coverFileLabel,
    required this.coverFileType,
    this.coverFileExtensions,
    required this.hideFile,
    required this.unhideFile,
    required this.hasHiddenContent,
    this.capacityInfo,
  });
}
