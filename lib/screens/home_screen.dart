import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'image_stego_screen.dart';
import 'media_category_screens.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _q = '';
  late AnimationController _hdr;
  late Animation<double> _hdrAnim;

  final _cards = const [
    _Card('image',    'Rasm bilan ishlash',    'Image Steganography',
        'PNG/JPG rasm ichiga fayl yashirish. LSB piksel usuli.',
        Icons.image_outlined, AppTheme.accent,
        ['rasm','image','hide','unhide','png','jpg','lsb']),
    _Card('audio',    'Audio bilan ishlash',   'Audio Steganography',
        'WAV (LSB) yoki MP3/FLAC/OGG fayllar ichiga fayl yashirish.',
        Icons.audiotrack, AppTheme.accentPurple,
        ['audio','wav','mp3','flac','ogg','aac','ovoz']),
    _Card('video',    'Video bilan ishlash',   'Video Steganography',
        'MP4, MKV, AVI, MOV video fayllar ichiga fayl yashirish.',
        Icons.videocam_outlined, Color(0xFFE91E8C),
        ['video','mp4','mkv','avi','mov','film']),
    _Card('document', 'Hujjat bilan ishlash',  'Document Steganography',
        'PDF, DOCX, XLSX, TXT hujjatlar ichiga fayl yashirish.',
        Icons.description_outlined, Color(0xFF10B981),
        ['hujjat','pdf','docx','xlsx','txt','word']),
    _Card('about',    'Steganografiya haqida', 'Ma\'lumot',
        'LSB usuli, shifrlash va boshqa ma\'lumotlar.',
        Icons.info_outline, AppTheme.accentGreen,
        ['haqida','about','info','lsb','shifr']),
  ];

  @override
  void initState() {
    super.initState();
    _hdr = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _hdrAnim = CurvedAnimation(parent: _hdr, curve: Curves.easeOut);
    _hdr.forward();
  }
  @override
  void dispose() { _searchCtrl.dispose(); _hdr.dispose(); super.dispose(); }

  List<_Card> get _filtered {
    if (_q.isEmpty) return _cards;
    final q = _q.toLowerCase();
    return _cards.where((c) =>
        c.title.toLowerCase().contains(q) ||
        c.subtitle.toLowerCase().contains(q) ||
        c.desc.toLowerCase().contains(q) ||
        c.tags.any((t) => t.contains(q))).toList();
  }

  void _go(String id) {
    final Widget s;
    switch (id) {
      case 'image':    s = const ImageStegoScreen(); break;
      case 'audio':    s = const AudioStegoPage(); break;
      case 'video':    s = const VideoStegoPage(); break;
      case 'document': s = const DocumentStegoPage(); break;
      case 'about':    s = const AboutScreen(); break;
      default: return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => s));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = AppTheme.isMobile(context);
    final pad = AppTheme.hPad(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(children: [
          _topBar(mobile),
          _searchBar(mobile, pad),
          Expanded(child: _filtered.isEmpty
              ? _noResults()
              : ListView(
                  padding: EdgeInsets.fromLTRB(pad, 4, pad, 20),
                  children: [
                    FadeTransition(opacity: _hdrAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.2), end: Offset.zero)
                            .animate(_hdrAnim),
                        child: _hero(mobile))),
                    SizedBox(height: mobile ? 14 : 18),
                    Text('AMALLAR', style: GoogleFonts.orbitron(
                        color: AppTheme.textSecondary,
                        fontSize: mobile ? 10 : 11, letterSpacing: 3)),
                    const SizedBox(height: 10),
                    ..._filtered.map((c) => Padding(
                        padding: EdgeInsets.only(bottom: mobile ? 8 : 10),
                        child: _cardWidget(c, mobile))),
                  ])),
        ]),
      ),
    );
  }

  Widget _topBar(bool mobile) => Padding(
    padding: EdgeInsets.symmetric(horizontal: AppTheme.hPad(context), vertical: 10),
    child: Row(children: [
      const Icon(Icons.visibility_off, color: AppTheme.accent, size: 20),
      const SizedBox(width: 8),
      Text('STEGANOGRAPHY', style: GoogleFonts.orbitron(
          color: AppTheme.accent,
          fontSize: mobile ? 14 : 16, letterSpacing: 3, fontWeight: FontWeight.bold)),
      const Spacer(),
      ...[AppTheme.accentGreen, AppTheme.accent, AppTheme.accentPurple,
          const Color(0xFFE91E8C), const Color(0xFF10B981)]
          .map((c) => Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(width: 6, height: 6,
                  decoration: BoxDecoration(color: c.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 4)])))),
    ]),
  );

  Widget _searchBar(bool mobile, double pad) => Container(
    margin: EdgeInsets.fromLTRB(pad, 0, pad, 10),
    height: mobile ? 40 : 44,
    decoration: BoxDecoration(
      color: AppTheme.bgCard,
      borderRadius: BorderRadius.circular(mobile ? 20 : 22),
      border: Border.all(color: _q.isNotEmpty
          ? AppTheme.accent.withValues(alpha: 0.5) : AppTheme.border)),
    child: Row(children: [
      const SizedBox(width: 12),
      Icon(Icons.search, color: AppTheme.textSecondary, size: mobile ? 16 : 18),
      const SizedBox(width: 8),
      Expanded(child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.spaceMono(
            color: AppTheme.textPrimary, fontSize: mobile ? 12 : 13),
        decoration: InputDecoration(
          hintText: 'Qidirish...',
          hintStyle: GoogleFonts.spaceMono(
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
              fontSize: mobile ? 11 : 12),
          border: InputBorder.none, enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none, isDense: true,
          contentPadding: EdgeInsets.zero),
        onChanged: (v) => setState(() => _q = v),
      )),
      if (_q.isNotEmpty)
        GestureDetector(
          onTap: () { _searchCtrl.clear(); setState(() => _q = ''); },
          child: Padding(padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.close, color: AppTheme.textSecondary, size: 15))),
    ]),
  );

  Widget _hero(bool mobile) => Container(
    padding: EdgeInsets.all(mobile ? 16 : 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppTheme.accent.withValues(alpha: 0.07),
              const Color(0xFFE91E8C).withValues(alpha: 0.04), AppTheme.bgCard]),
      borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.13))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 7, height: 7,
            decoration: const BoxDecoration(color: AppTheme.accentGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.accentGreen, blurRadius: 5)])),
        const SizedBox(width: 7),
        Text('FAOL', style: GoogleFonts.orbitron(
            color: AppTheme.accentGreen, fontSize: 10, letterSpacing: 2)),
      ]),
      SizedBox(height: mobile ? 8 : 12),
      Text('Ma\'lumotni\nyashirish platformasi',
          style: GoogleFonts.orbitron(color: AppTheme.textPrimary,
              fontSize: mobile ? 16 : 19, fontWeight: FontWeight.bold, height: 1.3)),
      SizedBox(height: mobile ? 6 : 8),
      Text('Rasm • Audio • Video • Hujjat — 4 tur uchun cross-platform steganografiya.',
          style: GoogleFonts.spaceMono(color: AppTheme.textSecondary,
              fontSize: mobile ? 11 : 12, height: 1.5)),
    ]),
  );

  Widget _cardWidget(_Card c, bool mobile) => GestureDetector(
    onTap: () => _go(c.id),
    child: Container(
      padding: EdgeInsets.all(mobile ? 12 : 15),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius(context)),
        border: Border.all(color: c.color.withValues(alpha: 0.18)),
        boxShadow: [BoxShadow(
            color: c.color.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(width: mobile ? 40 : 46, height: mobile ? 40 : 46,
            decoration: BoxDecoration(color: c.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: c.color.withValues(alpha: 0.22))),
            child: Icon(c.icon, color: c.color, size: mobile ? 20 : 22)),
        SizedBox(width: mobile ? 10 : 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.title, style: GoogleFonts.orbitron(color: AppTheme.textPrimary,
              fontSize: mobile ? 11 : 12, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          const SizedBox(height: 2),
          Text(c.subtitle, style: GoogleFonts.spaceMono(
              color: c.color.withValues(alpha: 0.8), fontSize: mobile ? 10 : 11)),
          const SizedBox(height: 3),
          Text(c.desc, style: GoogleFonts.spaceMono(
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
              fontSize: mobile ? 10 : 11, height: 1.4),
              maxLines: mobile ? 1 : 2, overflow: TextOverflow.ellipsis),
        ])),
        Icon(Icons.chevron_right, color: c.color.withValues(alpha: 0.45),
            size: mobile ? 18 : 20),
      ]),
    ),
  );

  Widget _noResults() => Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, color: AppTheme.textSecondary, size: 44),
        const SizedBox(height: 14),
        Text('"$_q" topilmadi', style: GoogleFonts.spaceMono(
            color: AppTheme.textSecondary, fontSize: 13)),
      ]));
}

class _Card {
  final String id, title, subtitle, desc;
  final IconData icon;
  final Color color;
  final List<String> tags;
  const _Card(this.id, this.title, this.subtitle, this.desc,
      this.icon, this.color, this.tags);
}
