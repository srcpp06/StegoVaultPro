import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import '../utils/app_theme.dart';

class FileDropZone extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? filePath;
  final Color color;
  final VoidCallback onTap;
  final bool isImage;

  const FileDropZone({
    super.key,
    required this.label,
    required this.icon,
    required this.filePath,
    required this.color,
    required this.onTap,
    this.isImage = false,
  });

  String _fmtSize(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final mobile = AppTheme.isMobile(context);
    final hasFile = filePath != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: mobile ? 72 : 90),
        decoration: BoxDecoration(
          color: hasFile ? color.withOpacity(0.06) : AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
          border: Border.all(
            color: hasFile ? color.withOpacity(0.5) : AppTheme.border,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: hasFile ? _withFile(context, mobile) : _empty(context, mobile),
      ),
    );
  }

  Widget _empty(BuildContext context, bool mobile) => Padding(
        padding: EdgeInsets.all(mobile ? 14 : 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color.withOpacity(0.4), size: mobile ? 26 : 32),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                  color: AppTheme.textSecondary, fontSize: mobile ? 12 : 13)),
          const SizedBox(height: 4),
          Text('Bosing yoki tanlang',
              style: GoogleFonts.spaceMono(
                  color: AppTheme.textSecondary.withOpacity(0.45),
                  fontSize: mobile ? 10 : 11)),
        ]),
      );

  Widget _withFile(BuildContext context, bool mobile) {
    final fileName = p.basename(filePath!);
    final file = File(filePath!);
    final fileSize = file.existsSync() ? _fmtSize(file.lengthSync()) : '';
    final ext = p.extension(filePath!).toLowerCase();
    final isImg = ['.png','.jpg','.jpeg','.bmp','.gif','.webp'].contains(ext);

    return Padding(
      padding: EdgeInsets.all(mobile ? 10 : 14),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: isImg
              ? Image.file(file,
                  width: mobile ? 44 : 56, height: mobile ? 44 : 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _iconBox(mobile))
              : _iconBox(mobile),
        ),
        SizedBox(width: mobile ? 10 : 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(fileName,
                style: GoogleFonts.spaceMono(
                    color: AppTheme.textPrimary,
                    fontSize: mobile ? 12 : 13, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            if (fileSize.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(fileSize,
                  style: GoogleFonts.spaceMono(
                      color: AppTheme.textSecondary, fontSize: mobile ? 10 : 11)),
            ],
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.check_circle, color: color, size: 11),
              const SizedBox(width: 4),
              Text('Tanlandi',
                  style: GoogleFonts.spaceMono(color: color, fontSize: mobile ? 10 : 11)),
            ]),
          ],
        )),
      ]),
    );
  }

  Widget _iconBox(bool mobile) {
    final size = mobile ? 44.0 : 56.0;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: mobile ? 22 : 26),
    );
  }
}
