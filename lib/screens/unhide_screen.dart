import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/steganography_service.dart';
import '../services/stego_utils.dart';
import '../utils/app_theme.dart';
import '../widgets/file_drop_zone.dart';
import '../widgets/result_card.dart';

class UnhideScreen extends StatefulWidget {
  const UnhideScreen({super.key});
  @override State<UnhideScreen> createState() => _UnhideScreenState();
}

class _UnhideScreenState extends State<UnhideScreen> with SingleTickerProviderStateMixin {
  String? _coverPath;
  final _pwCtrl = TextEditingController();
  bool _pwVisible = false;
  bool _processing = false;
  bool _needsPw = false;
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
    if (r?.files.single.path != null) {
      setState(() {
        _coverPath = r!.files.single.path;
        _result = null; _needsPw = false; _pwCtrl.clear();
      });
      final has = await SteganographyService.hasHiddenContent(_coverPath!);
      if (!has && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('⚠ Bu rasmda yashirilgan fayl topilmadi',
              style: GoogleFonts.spaceMono(fontSize: 12)),
          backgroundColor: AppTheme.warning));
      }
    }
  }

  Future<void> _unhide() async {
    if (_coverPath == null) { _snack('Rasm tanlang', AppTheme.error); return; }
    if (_needsPw && _pwCtrl.text.isEmpty) { _snack('Parol kiriting', AppTheme.error); return; }
    setState(() { _processing = true; _result = null; });
    try {
      final outDir = await StegoUtils.getOutputDir();
      final res = await SteganographyService.unhideFile(
        imagePath: _coverPath!, outputDir: outDir.path,
        password: _pwCtrl.text.isEmpty ? null : _pwCtrl.text,
      );
      if (res.message == 'PAROL_KERAK') {
        setState(() { _needsPw = true; _processing = false; });
        _snack('🔒 Fayl parollangan — parol kiriting', AppTheme.accentOrange);
        return;
      }
      setState(() => _result = res);
    } finally { if (mounted) setState(() => _processing = false); }
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.spaceMono(fontSize: 12)), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    final mobile = AppTheme.isMobile(context);
    final pad = AppTheme.hPad(context);
    final pwColor = _needsPw ? AppTheme.error : AppTheme.accentOrange;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.lock_open, size: 18, color: AppTheme.accentOrange),
          const SizedBox(width: 8),
          Text('RASM — UNHIDE', style: GoogleFonts.orbitron(
              color: AppTheme.accentOrange, fontSize: mobile ? 13 : 15, letterSpacing: 2)),
        ]),
        backgroundColor: AppTheme.bgDeep,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.accentOrange.withOpacity(0.3))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoBox(mobile),
          SizedBox(height: mobile ? 16 : 22),
          _label('01', 'RASM FAYL', AppTheme.accentOrange, mobile),
          const SizedBox(height: 8),
          FileDropZone(label: 'Yashirilgan faylli rasmni tanlang (PNG)',
              icon: Icons.image_search, filePath: _coverPath,
              color: AppTheme.accentOrange, onTap: _pickImage, isImage: true),
          SizedBox(height: mobile ? 14 : 18),
          _label('02', _needsPw ? 'PAROL (MAJBURIY)' : 'PAROL', pwColor, mobile),
          const SizedBox(height: 8),
          _pwField(pwColor),
          if (_needsPw) ...[
            const SizedBox(height: 6),
            Text('🔒 Fayl parollangan — to\'g\'ri parol kiriting',
                style: GoogleFonts.spaceMono(
                    color: AppTheme.error.withOpacity(0.8),
                    fontSize: mobile ? 10 : 11)),
          ],
          SizedBox(height: mobile ? 20 : 28),
          _unhideBtn(mobile),
          const SizedBox(height: 20),
          if (_result != null) ResultCard(result: _result!),
        ]),
      ),
    );
  }

  Widget _infoBox(bool mobile) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.accentOrange.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2))),
    child: Row(children: [
      const Icon(Icons.info_outline, color: AppTheme.accentOrange, size: 15),
      const SizedBox(width: 8),
      Expanded(child: Text(
        'Faqat PNG formatidagi rasm ishlatilishi mumkin.\nParol avtomatik aniqlanadi.',
        style: GoogleFonts.spaceMono(
            color: AppTheme.accentOrange.withOpacity(0.8),
            fontSize: mobile ? 10 : 12))),
    ]),
  );

  Widget _label(String n, String t, Color c, bool mobile) => Row(children: [
    Container(width: 22, height: 22,
        decoration: BoxDecoration(color: c.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: c.withOpacity(0.35))),
        child: Center(child: Text(n, style: GoogleFonts.orbitron(
            color: c, fontSize: 9, fontWeight: FontWeight.bold)))),
    const SizedBox(width: 8),
    Text(t, style: GoogleFonts.orbitron(color: AppTheme.textPrimary,
        fontSize: mobile ? 11 : 12, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
  ]);

  Widget _pwField(Color pwColor) => TextField(
    controller: _pwCtrl, obscureText: !_pwVisible,
    style: GoogleFonts.spaceMono(color: AppTheme.textPrimary, fontSize: 13),
    decoration: InputDecoration(
      hintText: _needsPw ? 'Parolni kiriting...' : 'Parol (ixtiyoriy)...',
      prefixIcon: Icon(Icons.lock_outline, color: pwColor, size: 17),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _needsPw
              ? AppTheme.error.withOpacity(0.5) : AppTheme.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: pwColor, width: 1.5)),
      suffixIcon: IconButton(
        icon: Icon(_pwVisible ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textSecondary, size: 17),
        onPressed: () => setState(() => _pwVisible = !_pwVisible)),
    ),
  );

  Widget _unhideBtn(bool mobile) => SizedBox(
    width: double.infinity, height: 50,
    child: AnimatedBuilder(animation: _glow, builder: (_, __) => Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        boxShadow: _coverPath != null ? [BoxShadow(
            color: AppTheme.accentOrange.withOpacity(0.15 + _glow.value * 0.25),
            blurRadius: 20, spreadRadius: 2)] : []),
      child: ElevatedButton.icon(
        onPressed: _processing ? null : _unhide,
        style: ElevatedButton.styleFrom(
          backgroundColor: _processing ? AppTheme.bgElevated : AppTheme.accentOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        icon: _processing
            ? const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentOrange))
            : const Icon(Icons.lock_open, size: 18),
        label: Text(_processing ? 'CHIQARILMOQDA...' : 'UNHIDE — CHIQARISH',
            style: GoogleFonts.orbitron(fontWeight: FontWeight.w700,
                letterSpacing: 2, fontSize: mobile ? 12 : 13,
                color: _processing ? AppTheme.accentOrange : Colors.white)),
      ),
    )),
  );
}
