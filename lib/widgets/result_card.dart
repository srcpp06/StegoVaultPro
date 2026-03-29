import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/stego_utils.dart';
import '../utils/app_theme.dart';

class ResultCard extends StatelessWidget {
  final StegoResult result;
  const ResultCard({super.key, required this.result});

  void _openFolder(BuildContext ctx, String filePath) async {
    if (Platform.isLinux) {
      Process.run('xdg-open', [File(filePath).parent.path]);
    } else if (Platform.isMacOS) {
      Process.run('open', [File(filePath).parent.path]);
    } else if (Platform.isWindows) {
      Process.run('explorer', [File(filePath).parent.path]);
    } else {
      // Mobile: share the file
      try {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Steganography - yashirilgan fayl',
        );
      } catch (e) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('Ulashishda xato: $e',
                style: GoogleFonts.spaceMono(fontSize: 12)),
            backgroundColor: AppTheme.error,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ok    = result.success;
    final color = ok ? AppTheme.success : AppTheme.error;
    final icon  = ok ? Icons.check_circle_outline : Icons.error_outline;
    final mobile = AppTheme.isMobile(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20)],
      ),
      padding: EdgeInsets.all(mobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: mobile ? 18 : 22),
            const SizedBox(width: 8),
            Text(ok ? 'MUVAFFAQIYATLI' : 'XATO',
                style: GoogleFonts.orbitron(
                    color: color, fontSize: mobile ? 12 : 14,
                    letterSpacing: 2, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          Text(result.message,
              style: GoogleFonts.spaceMono(
                  color: AppTheme.textPrimary, fontSize: mobile ? 12 : 13)),

          if (ok && result.outputPath != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: EdgeInsets.all(mobile ? 10 : 12),
              decoration: BoxDecoration(
                color: AppTheme.bgDeep,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAQLANGAN JOY:',
                      style: GoogleFonts.orbitron(
                          color: AppTheme.textSecondary,
                          fontSize: 9, letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: Text(
                      Platform.isAndroid || Platform.isIOS
                          ? StegoUtils.outputDirLabel(result.outputPath!)
                          : result.outputPath!,
                      style: GoogleFonts.spaceMono(
                          color: color, fontSize: mobile ? 11 : 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 15),
                      color: AppTheme.textSecondary,
                      tooltip: 'Nusxalash',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: result.outputPath!));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Nusxalandi',
                              style: GoogleFonts.spaceMono(fontSize: 12)),
                          backgroundColor: AppTheme.bgElevated,
                          duration: const Duration(seconds: 1),
                        ));
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openFolder(context, result.outputPath!),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: mobile ? 10 : 12),
                ),
                icon: Icon(
                  Platform.isAndroid || Platform.isIOS
                      ? Icons.share : Icons.folder_open,
                  size: 16),
                label: Text(
                  Platform.isAndroid || Platform.isIOS
                      ? 'FAYLNI ULASHISH' : 'PAPKANI OCHISH',
                  style: GoogleFonts.orbitron(
                      fontSize: mobile ? 11 : 12,
                      letterSpacing: 1.5, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
