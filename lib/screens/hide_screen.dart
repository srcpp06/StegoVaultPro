import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/steganography_service.dart';
import '../services/stego_utils.dart';
import '../utils/app_theme.dart';
import '../widgets/file_drop_zone.dart';
import '../widgets/result_card.dart';

class HideScreen extends StatefulWidget {
  const HideScreen({super.key});
  @override State<HideScreen> createState() => _HideScreenState();
}

class _HideScreenState extends State<HideScreen> with SingleTickerProviderStateMixin {
  String? _coverPath;
  String? _secretPath;
  final _pwCtrl = TextEditingController();
  bool _pwVisible = false;
  bool _processing = false;
  StegoResult? _result;
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _pwCtrl.dispose(); _glow.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r?.files.single.path != null)
      setState(() { _coverPath = r!.files.single.path; _result = null; });
  }
  Future<void> _pickSecret() async {
    final r = await FilePicker.platform.pickFiles();
    if (r?.files.single.path != null)
      setState(() { _secretPath = r!.files.single.path; _result = null; });
  }

  Future<void> _hide() async {
    if (_coverPath == null || _secretPath == null) {
      _snack('Rasm va yashiriladigan faylni tanlang', AppTheme.error); return;
    }
    setState(() { _processing = true; _result = null; });
    try {
      final outDir = await StegoUtils.getOutputDir();
      final res = await SteganographyService.hideFile(
        imagePath: _coverPath!, filePath: _secretPath!,
        outputDir: outDir.path,
        password: _pwCtrl.text.isEmpty ? null : _pwCtrl.text,
      );
      setState(() => _result = res);
    } finally { if (mounted) setState(() => _processing = false); }
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.spaceMono(fontSize: 12)),
          backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    final mobile = AppTheme.isMobile(context);
    final pad = AppTheme.hPad(context);
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.lock, size: 18, color: AppTheme.accentGreen),
          const SizedBox(width: 8),
          Text('RASM — HIDE', style: GoogleFonts.orbitron(
              color: AppTheme.accentGreen, fontSize: mobile ? 13 : 15, letterSpacing: 2)),
        ]),
        backgroundColor: AppTheme.bgDeep,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.accentGreen.withOpacity(0.3))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoBox(),
          SizedBox(height: mobile ? 16 : 22),
          _label('01', 'COVER RASM'),
          const SizedBox(height: 8),
          FileDropZone(label: 'Rasm tanlang (PNG, JPG)',
              icon: Icons.image_outlined, filePath: _coverPath,
              color: AppTheme.accent, onTap: _pickImage, isImage: true),
          SizedBox(height: mobile ? 14 : 18),
          _label('02', 'YASHIRILADIGAN FAYL'),
          const SizedBox(height: 8),
          FileDropZone(label: 'Har qanday fayl',
              icon: Icons.attach_file, filePath: _secretPath,
              color: AppTheme.accentPurple, onTap: _pickSecret),
          SizedBox(height: mobile ? 14 : 18),
          _label('03', 'PAROL (ixtiyoriy)'),
          const SizedBox(height: 8),
          _pwField(),
          const SizedBox(height: 6),
          Text('⚠ Parol boshqa qurilmada ham ishlaydi',
              style: GoogleFonts.spaceMono(
                  color: AppTheme.warning.withOpacity(0.7),
                  fontSize: mobile ? 10 : 11)),
          SizedBox(height: mobile ? 20 : 28),
          _hideBtn(),
          const SizedBox(height: 20),
          if (_result != null) ResultCard(result: _result!),
        ]),
      ),
    );
  }

  Widget _infoBox() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.accentGreen.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.accentGreen.withOpacity(0.2))),
    child: Row(children: [
      const Icon(Icons.info_outline, color: AppTheme.accentGreen, size: 15),
      const SizedBox(width: 8),
      Expanded(child: Text('Natija PNG formatida saqlanadi (LSB uchun zarur).',
          style: GoogleFonts.spaceMono(
              color: AppTheme.accentGreen.withOpacity(0.8),
              fontSize: AppTheme.isMobile(context) ? 11 : 12))),
    ]),
  );

  Widget _label(String n, String t) => Row(children: [
    Container(width: 22, height: 22,
        decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.accent.withOpacity(0.35))),
        child: Center(child: Text(n, style: GoogleFonts.orbitron(
            color: AppTheme.accent, fontSize: 9, fontWeight: FontWeight.bold)))),
    const SizedBox(width: 8),
    Text(t, style: GoogleFonts.orbitron(color: AppTheme.textPrimary,
        fontSize: AppTheme.isMobile(context) ? 11 : 12,
        letterSpacing: 1.5, fontWeight: FontWeight.w600)),
  ]);

  Widget _pwField() => TextField(
    controller: _pwCtrl, obscureText: !_pwVisible,
    style: GoogleFonts.spaceMono(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Parol (ixtiyoriy)...',
      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.accentOrange, size: 17),
      suffixIcon: IconButton(
        icon: Icon(_pwVisible ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textSecondary, size: 17),
        onPressed: () => setState(() => _pwVisible = !_pwVisible)),
    ),
  );

  Widget _hideBtn() => SizedBox(
    width: double.infinity, height: 50,
    child: AnimatedBuilder(animation: _glow, builder: (_, __) => Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        boxShadow: _coverPath != null && _secretPath != null ? [BoxShadow(
            color: AppTheme.accentGreen.withOpacity(0.2 + _glow.value * 0.3),
            blurRadius: 20, spreadRadius: 2)] : []),
      child: ElevatedButton.icon(
        onPressed: _processing ? null : _hide,
        style: ElevatedButton.styleFrom(
          backgroundColor: _processing ? AppTheme.bgElevated : AppTheme.accentGreen,
          foregroundColor: AppTheme.bgDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        icon: _processing
            ? SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGreen))
            : const Icon(Icons.lock, size: 18),
        label: Text(_processing ? 'YASHIRILMOQDA...' : 'HIDE — YASHIRISH',
            style: GoogleFonts.orbitron(fontWeight: FontWeight.w700,
                letterSpacing: 2, fontSize: AppTheme.isMobile(context) ? 12 : 13,
                color: _processing ? AppTheme.accentGreen : AppTheme.bgDeep)),
      ),
    )),
  );
}
