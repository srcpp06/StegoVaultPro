import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../models/stego_config.dart';
import '../services/audio_stego_service.dart';
import '../services/video_stego_service.dart';
import '../services/document_stego_service.dart';
import '../utils/app_theme.dart';
import 'generic_hide_screen.dart';
import 'generic_unhide_screen.dart';

// ── Generic Category Screen ───────────────────────────────────────────────────

class GenericCategoryScreen extends StatelessWidget {
  final StegoConfig config;
  final List<InfoItem> infoItems;
  final String methodDescription;

  const GenericCategoryScreen({
    super.key,
    required this.config,
    required this.infoItems,
    required this.methodDescription,
  });

  @override
  Widget build(BuildContext context) {
    final color = config.primaryColor;
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          Icon(config.icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text('${config.displayName.toUpperCase()} BILAN ISHLASH',
              style: GoogleFonts.orbitron(color: color, fontSize: 13, letterSpacing: 2)),
        ]),
        backgroundColor: AppTheme.bgDeep,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amal tanlang',
                style: GoogleFonts.spaceMono(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 18),
            _ActionCard(
              title: 'HIDE', subtitle: 'Yashirish',
              description:
                  '${config.displayName} fayli ichiga boshqa fayl yashirish.\nParol bilan himoya qilish mumkin.',
              icon: Icons.lock, color: color,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => GenericHideScreen(config: config))),
            ),
            const SizedBox(height: 14),
            _ActionCard(
              title: 'UNHIDE', subtitle: 'Chiqarish',
              description:
                  '${config.displayName} faylidan yashirilgan faylni chiqarish.\nParol kerak bo\'lsa avtomatik so\'raladi.',
              icon: Icons.lock_open, color: AppTheme.accentOrange,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => GenericUnhideScreen(config: config))),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.info_outline, color: color, size: 15),
                  const SizedBox(width: 8),
                  Text('${config.displayName} steganografiyasi',
                      style: GoogleFonts.orbitron(color: color, fontSize: 11, letterSpacing: 1)),
                ]),
                const SizedBox(height: 10),
                Text(methodDescription,
                    style: GoogleFonts.spaceMono(
                        color: AppTheme.textSecondary, fontSize: 11, height: 1.6)),
                const SizedBox(height: 10),
                ...infoItems.map((item) =>
                    _InfoRow(icon: item.icon, text: item.text, color: color)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoItem {
  final IconData icon;
  final String text;
  const InfoItem(this.icon, this.text);
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(children: [
          Icon(icon, color: color.withOpacity(0.6), size: 13),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.spaceMono(
              color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11))),
        ]),
      );
}

class _ActionCard extends StatelessWidget {
  final String title, subtitle, description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({
    required this.title, required this.subtitle, required this.description,
    required this.icon, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.28)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.07), blurRadius: 18, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: GoogleFonts.orbitron(
                    color: color, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(width: 8),
                Text('— $subtitle', style: GoogleFonts.spaceMono(
                    color: AppTheme.textSecondary, fontSize: 12)),
              ]),
              const SizedBox(height: 5),
              Text(description, style: GoogleFonts.spaceMono(
                  color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11, height: 1.5)),
            ])),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 15),
          ]),
        ),
      );
}

// ── Preconfigured Pages ───────────────────────────────────────────────────────

class AudioStegoPage extends StatelessWidget {
  const AudioStegoPage({super.key});

  @override
  Widget build(BuildContext context) => GenericCategoryScreen(
        config: StegoConfig(
          categoryKey: 'audio',
          displayName: 'Audio',
          primaryColor: AppTheme.accentPurple,
          icon: Icons.audiotrack,
          coverFileLabel: 'Audio tanlang (WAV, MP3, FLAC, OGG, AAC)',
          coverFileType: FileType.custom,
          coverFileExtensions: ['wav', 'mp3', 'flac', 'ogg', 'aac', 'm4a', 'wma'],
          hideFile: ({required coverPath, required filePath, required outputDir, password}) =>
              AudioStegoService.hideFile(
                  audioPath: coverPath, filePath: filePath, outputDir: outputDir, password: password),
          unhideFile: ({required coverPath, required outputDir, password}) =>
              AudioStegoService.unhideFile(
                  audioPath: coverPath, outputDir: outputDir, password: password),
          hasHiddenContent: AudioStegoService.hasHiddenContent,
          capacityInfo: AudioStegoService.getCapacityInfo,
        ),
        methodDescription:
            'WAV fayllar uchun LSB usuli — audio namunalar ichiga ma\'lumot '
            'yoziladi, quloq bilan eshitib bo\'lmaydi.\nMP3/FLAC/OGG uchun '
            'konteyner oxiriga qo\'shimcha usuli.',
        infoItems: const [
          InfoItem(Icons.music_note, 'WAV: LSB — audio sifatiga ta\'sir qilmaydi'),
          InfoItem(Icons.audio_file, 'MP3/FLAC/OGG: Append usuli'),
          InfoItem(Icons.lock, 'SHA-256 + XOR shifrlash'),
          InfoItem(Icons.drive_file_rename_outline, 'Fayl nomlari o\'zgarmaydi'),
        ],
      );
}

class VideoStegoPage extends StatelessWidget {
  const VideoStegoPage({super.key});

  @override
  Widget build(BuildContext context) => GenericCategoryScreen(
        config: StegoConfig(
          categoryKey: 'video',
          displayName: 'Video',
          primaryColor: const Color(0xFFE91E8C),
          icon: Icons.videocam_outlined,
          coverFileLabel: 'Video tanlang (MP4, MKV, AVI, MOV, WebM)',
          coverFileType: FileType.custom,
          coverFileExtensions: ['mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'wmv', 'ts', 'm4v'],
          hideFile: ({required coverPath, required filePath, required outputDir, password}) =>
              VideoStegoService.hideFile(
                  videoPath: coverPath, filePath: filePath, outputDir: outputDir, password: password),
          unhideFile: ({required coverPath, required outputDir, password}) =>
              VideoStegoService.unhideFile(
                  videoPath: coverPath, outputDir: outputDir, password: password),
          hasHiddenContent: VideoStegoService.hasHiddenContent,
        ),
        methodDescription:
            'Video konteyner oxiriga shifrlangan ma\'lumot yoziladi. '
            'MP4, MKV, AVI pleerlar bu qo\'shimchani e\'tiborsiz qoldiradi — '
            'video odatdagidek ijro etiladi.',
        infoItems: const [
          InfoItem(Icons.video_file, 'MP4, MKV, AVI, MOV — barchasi qo\'llaniladi'),
          InfoItem(Icons.play_circle_outline, 'Video ijro etilishiga ta\'sir qilmaydi'),
          InfoItem(Icons.lock, 'SHA-256 + XOR shifrlash'),
          InfoItem(Icons.drive_file_rename_outline, 'Fayl nomlari o\'zgarmaydi'),
        ],
      );
}

class DocumentStegoPage extends StatelessWidget {
  const DocumentStegoPage({super.key});

  @override
  Widget build(BuildContext context) => GenericCategoryScreen(
        config: StegoConfig(
          categoryKey: 'document',
          displayName: 'Hujjat',
          primaryColor: const Color(0xFF10B981),
          icon: Icons.description_outlined,
          coverFileLabel: 'Hujjat tanlang (PDF, DOCX, XLSX, TXT...)',
          coverFileType: FileType.custom,
          coverFileExtensions: [
            'pdf', 'docx', 'doc', 'xlsx', 'xls', 'pptx', 'ppt',
            'txt', 'rtf', 'odt', 'ods', 'odp', 'csv'
          ],
          hideFile: ({required coverPath, required filePath, required outputDir, password}) =>
              DocumentStegoService.hideFile(
                  docPath: coverPath, filePath: filePath, outputDir: outputDir, password: password),
          unhideFile: ({required coverPath, required outputDir, password}) =>
              DocumentStegoService.unhideFile(
                  docPath: coverPath, outputDir: outputDir, password: password),
          hasHiddenContent: DocumentStegoService.hasHiddenContent,
        ),
        methodDescription:
            'Hujjat faylining oxiriga yashirilgan ma\'lumot qo\'shiladi. '
            'PDF, DOCX, XLSX dasturlari bu qo\'shimchani ko\'rmaydi — '
            'hujjat odatdagidek ochiladi va ko\'rinishi o\'zgarmaydi.',
        infoItems: const [
          InfoItem(Icons.picture_as_pdf, 'PDF, DOCX, XLSX, TXT — barchasi'),
          InfoItem(Icons.open_in_new, 'Hujjat odatdagidek ochiladi'),
          InfoItem(Icons.lock, 'SHA-256 + XOR shifrlash'),
          InfoItem(Icons.drive_file_rename_outline, 'Fayl nomlari o\'zgarmaydi'),
        ],
      );
}
