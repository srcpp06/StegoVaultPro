import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stego_config.dart';
import '../services/stego_utils.dart';
import '../utils/app_theme.dart';
import '../widgets/file_drop_zone.dart';
import '../widgets/result_card.dart';

class GenericHideScreen extends StatefulWidget {
  final StegoConfig config;
  const GenericHideScreen({super.key, required this.config});
  @override State<GenericHideScreen> createState() => _State();
}

class _State extends State<GenericHideScreen> with SingleTickerProviderStateMixin {
  String? _coverPath;
  String? _secretPath;
  final _pwCtrl = TextEditingController();
  bool _pwVisible = false;
  bool _processing = false;
  StegoResult? _result;
  late AnimationController _glow;

  StegoConfig get cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }
  @override void dispose() { _pwCtrl.dispose(); _glow.dispose(); super.dispose(); }

  Future<void> _pickCover() async {
    final r = await FilePicker.platform.pickFiles(
        type: cfg.coverFileType,
        allowedExtensions: cfg.coverFileExtensions);
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
      _snack('Fayl va ${cfg.displayName.toLowerCase()}ni tanlang', AppTheme.error); return;
    }
    setState(() { _processing = true; _result = null; });
    try {
      final outDir = await StegoUtils.getOutputDir();
      final res = await cfg.hideFile(
        coverPath: _coverPath!, filePath: _secretPath!,
        outputDir: outDir.path,
        password: _pwCtrl.text.isEmpty ? null : _pwCtrl.text,
      );
      setState(() => _result = res);
    } finally { if (mounted) setState(() => _processing = false); }
  }

  void _snack(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.spaceMono(fontSize: 12)), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    final mobile = AppTheme.isMobile(context);
    final color = cfg.primaryColor;
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          Icon(Icons.lock, size: 17, color: color),
          const SizedBox(width: 7),
          Text('${cfg.displayName.toUpperCase()} — HIDE',
              style: GoogleFonts.orbitron(color: color,
                  fontSize: mobile ? 12 : 14, letterSpacing: 2)),
        ]),
        backgroundColor: AppTheme.bgDeep,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: color.withOpacity(0.3))),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.hPad(context)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoBox(color, mobile),
          SizedBox(height: mobile ? 16 : 22),
          _lbl('01', 'COVER — ${cfg.displayName.toUpperCase()}', mobile),
          const SizedBox(height: 8),
          FileDropZone(label: cfg.coverFileLabel, icon: cfg.icon,
              filePath: _coverPath, color: color, onTap: _pickCover),
          if (cfg.capacityInfo != null && _coverPath != null) ...[
            const SizedBox(height: 5),
            Row(children: [
              Icon(Icons.storage, color: color.withOpacity(0.6), size: 12),
              const SizedBox(width: 5),
              Text(cfg.capacityInfo!(_coverPath),
                  style: GoogleFonts.spaceMono(
                      color: color.withOpacity(0.7), fontSize: mobile ? 10 : 11)),
            ]),
          ],
          SizedBox(height: mobile ? 14 : 18),
          _lbl('02', 'YASHIRILADIGAN FAYL', mobile),
          const SizedBox(height: 8),
          FileDropZone(label: 'Har qanday fayl', icon: Icons.attach_file,
              filePath: _secretPath, color: AppTheme.accentPurple, onTap: _pickSecret),
          SizedBox(height: mobile ? 14 : 18),
          _lbl('03', 'PAROL (ixtiyoriy)', mobile),
          const SizedBox(height: 8),
          TextField(
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
          ),
          const SizedBox(height: 6),
          Text('⚠ Parol boshqa qurilmada ham ishlaydi',
              style: GoogleFonts.spaceMono(
                  color: AppTheme.warning.withOpacity(0.7), fontSize: mobile ? 10 : 11)),
          SizedBox(height: mobile ? 20 : 28),
          _btn(color, mobile),
          const SizedBox(height: 20),
          if (_result != null) ResultCard(result: _result!),
        ]),
      ),
    );
  }

  Widget _infoBox(Color color, bool mobile) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Row(children: [
      Icon(Icons.info_outline, color: color, size: 14),
      const SizedBox(width: 8),
      Expanded(child: Text('${cfg.displayName} fayli ichiga boshqa fayl yashirish.',
          style: GoogleFonts.spaceMono(color: color.withOpacity(0.8),
              fontSize: mobile ? 11 : 12))),
    ]),
  );

  Widget _lbl(String n, String t, bool mobile) => Row(children: [
    Container(width: 22, height: 22,
        decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.accent.withOpacity(0.35))),
        child: Center(child: Text(n, style: GoogleFonts.orbitron(
            color: AppTheme.accent, fontSize: 9, fontWeight: FontWeight.bold)))),
    const SizedBox(width: 8),
    Expanded(child: Text(t, style: GoogleFonts.orbitron(color: AppTheme.textPrimary,
        fontSize: mobile ? 10 : 12, letterSpacing: 1.2, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis)),
  ]);

  Widget _btn(Color color, bool mobile) => SizedBox(
    width: double.infinity, height: 50,
    child: AnimatedBuilder(animation: _glow, builder: (_, __) => Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        boxShadow: _coverPath != null && _secretPath != null ? [BoxShadow(
            color: color.withOpacity(0.2 + _glow.value * 0.3),
            blurRadius: 20)] : []),
      child: ElevatedButton.icon(
        onPressed: _processing ? null : _hide,
        style: ElevatedButton.styleFrom(
          backgroundColor: _processing ? AppTheme.bgElevated : color,
          foregroundColor: AppTheme.bgDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        icon: _processing
            ? SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : const Icon(Icons.lock, size: 18),
        label: Text(_processing ? 'YASHIRILMOQDA...' : 'HIDE — YASHIRISH',
            style: GoogleFonts.orbitron(fontWeight: FontWeight.w700,
                letterSpacing: 2, fontSize: mobile ? 12 : 13,
                color: _processing ? color : AppTheme.bgDeep)),
      ),
    )),
  );
}
