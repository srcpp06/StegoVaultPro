import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text('HAQIDA', style: GoogleFonts.orbitron(
          color: AppTheme.accent, fontSize: 15, letterSpacing: 2,
        )),
        backgroundColor: AppTheme.bgDeep,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo area
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.visibility_off, color: AppTheme.accent, size: 38),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'STEGANOGRAPHY',
                    style: GoogleFonts.orbitron(
                      color: AppTheme.accent,
                      fontSize: 20,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'v1.0.0',
                    style: GoogleFonts.spaceMono(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const _Section(
              title: 'STEGANOGRAFIYA NIMA?',
              icon: Icons.help_outline,
              color: AppTheme.accent,
              content:
                  'Steganografiya — ma\'lumotni boshqa ma\'lumot ichiga ko\'rinmas tarzda yashirish san\'ati va ilmi. '
                  '"Steganographia" yunoncha "yopiq yozuv" ma\'nosini anglatadi.\n\n'
                  'Kriptografiyadan farqli ravishda, steganografiya ma\'lumotning mavjudligini ham yashiradi — '
                  'faqat shifrlamaydi.',
            ),
            const SizedBox(height: 16),

            const _Section(
              title: 'LSB USULI',
              icon: Icons.memory,
              color: AppTheme.accentGreen,
              content:
                  'Bu ilova LSB (Least Significant Bit — eng kichik bit) usulidan foydalanadi.\n\n'
                  'Har bir pikselning R, G, B kanallarining oxirgi bitiga ma\'lumot bityozi.\n\n'
                  'Insonning ko\'zi bu o\'zgarishni ilg\'ay olmaydi — piksel rangi amalda o\'zgarmaydi.',
            ),
            const SizedBox(height: 16),

            const _Section(
              title: 'SHIFRLASH',
              icon: Icons.lock,
              color: AppTheme.accentOrange,
              content:
                  'Parol qo\'yilganda:\n'
                  '• SHA-256 orqali 256-bitli kalit yaratiladi\n'
                  '• XOR shifrlash bilan fayl himoyalanadi\n'
                  '• Noto\'g\'ri parol bilan fayl ochilmaydi\n\n'
                  'Parol boshqa qurilmada ham ishlaydi — algoritmlar standart.',
            ),
            const SizedBox(height: 16),

            const _Section(
              title: 'FAYL NOMLARI',
              icon: Icons.drive_file_rename_outline,
              color: AppTheme.accentPurple,
              content:
                  '• Chiquvchi rasm fayli nomi o\'zgarmaydi (asl nomi saqlanadi)\n'
                  '• Yashirilgan fayl nomi ham rasm ichida saqlanadi\n'
                  '• Unhide qilganda fayl asl nomi bilan chiqariladi\n'
                  '• Hech qanday nom o\'zgarmaydi',
            ),
            const SizedBox(height: 16),

            const _Section(
              title: 'QUVVAT CHEGARASI',
              icon: Icons.storage,
              color: AppTheme.accent,
              content:
                  '🖼 Rasm: (kengligi × balandligi × 3) / 8 bayt\n'
                  '   1920×1080 rasm ≈ 777 KB sig\'im\n\n'
                  '🎵 WAV audio: Fayl hajmining ~12.5% sig\'im\n\n'
                  '🎬 Video va 📄 Hujjat: Cheklov yo\'q (append usuli)',
            ),
            const SizedBox(height: 16),
            const _Section(
              title: '4 TUR MEDIA',
              icon: Icons.layers,
              color: AppTheme.accentPurple,
              content:
                  '🖼 Rasm (PNG/JPG) — LSB piksel usuli\n'
                  '🎵 Audio (WAV/MP3/FLAC/OGG) — WAV:LSB, boshqalar:Append\n'
                  '🎬 Video (MP4/MKV/AVI/MOV) — Konteyner Append usuli\n'
                  '📄 Hujjat (PDF/DOCX/XLSX/TXT) — Fayl Append usuli\n\n'
                  'Barcha usullarda fayl nomlari o\'zgarmaydi va\n'
                  'media fayllar odatdagidek ishlatilishda davom etadi.',
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                '© Steganography App',
                style: GoogleFonts.spaceMono(
                  color: AppTheme.textSecondary.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.spaceMono(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
