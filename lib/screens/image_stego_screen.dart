import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'hide_screen.dart';
import 'unhide_screen.dart';

class ImageStegoScreen extends StatelessWidget {
  const ImageStegoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Text('RASM BILAN ISHLASH', style: GoogleFonts.orbitron(
          color: AppTheme.accent, fontSize: 15, letterSpacing: 2,
        )),
        backgroundColor: AppTheme.bgDeep,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amal tanlang',
              style: GoogleFonts.spaceMono(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            _ActionCard(
              title: 'HIDE',
              subtitle: 'Yashirish',
              description: 'Rasm ichiga fayl yashirish.\nParol bilan himoya qilish mumkin.',
              icon: Icons.lock,
              color: AppTheme.accentGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HideScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              title: 'UNHIDE',
              subtitle: 'Chiqarish',
              description: 'Rasm ichidagi yashirilgan faylni chiqarish.\nParollangan fayllar uchun parol kerak.',
              icon: Icons.lock_open,
              color: AppTheme.accentOrange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnhideScreen()),
              ),
            ),
            const Spacer(),
            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.accent, size: 16),
                      const SizedBox(width: 8),
                      Text('Steganografiya haqida',
                          style: GoogleFonts.orbitron(
                            color: AppTheme.accent, fontSize: 12, letterSpacing: 1,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Steganografiya — ma\'lumotni boshqa ma\'lumot ichiga yashirish san\'ati. '
                    'Rasm piksellarining oxirgi bitiga ma\'lumot yoziladi (LSB usuli). '
                    'Ko\'z bilan ko\'rish mumkin emas.',
                    style: GoogleFonts.spaceMono(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.image, text: 'Kiruvchi va chiquvchi fayl nomlari o\'zgarmaydi'),
                  _InfoRow(icon: Icons.lock, text: 'Parol SHA-256 + XOR bilan shifrlash'),
                  _InfoRow(icon: Icons.devices, text: 'Parol bilan boshqa qurilmada ham ochiladi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent.withValues(alpha: 0.6), size: 13),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.spaceMono(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.orbitron(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '— $subtitle',
                        style: GoogleFonts.spaceMono(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.spaceMono(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
