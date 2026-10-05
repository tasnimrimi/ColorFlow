import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gradient_art.dart';
import 'sketchbook.dart';

const ink = Color(0xFF293E38),
    muted = Color(0xFF606C65),
    accent = Color(0xFF365F50);
const cream = Color(0xFFF8F6F0), lilac = Color(0xFFDCE8DC);
final _hexColorPattern = RegExp(r'^[0-9a-fA-F]{6}$');
final _studioCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: const Color(0xFFDBE1D9)),
  boxShadow: const [
    BoxShadow(
      color: Color(0x0C334D40),
      offset: Offset(0, 6),
      blurRadius: 24,
    ),
  ],
);
const palettes = <String, List<Color>>{
  'Rainbow': [
    Color(0xFFFF3B5C),
    Color(0xFFFF9234),
    Color(0xFFFFDA4A),
    Color(0xFF44CC78),
    Color(0xFF36B7FF),
    Color(0xFF6554E8),
    Color(0xFFBE4DDE),
  ],
  'Daydream': [Color(0xFFB7CCFF), Color(0xFFD4B7F5), Color(0xFFFFC9B5)],
  'Afterglow': [Color(0xFF7028E4), Color(0xFFE95D95), Color(0xFFFFBD80)],
  'Lagoon': [Color(0xFF124C8E), Color(0xFF46B8BE), Color(0xFFC5F1BA)],
  'Sorbet': [Color(0xFFFF83A1), Color(0xFFFFBC92), Color(0xFFFFE8A3)],
  'Midnight': [Color(0xFF151A44), Color(0xFF514289), Color(0xFFB68BC3)],
};
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Colorflow',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        surface: Colors.white,
        onSurface: ink,
        secondaryContainer: lilac,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF557B6B),
        inactiveTrackColor: Color(0xFFE5E7DD),
        thumbColor: ink,
        trackHeight: 4,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: muted),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? lilac : Colors.white,
          ),
          foregroundColor: WidgetStateProperty.all(ink),
          side: WidgetStateProperty.all(
            const BorderSide(color: Color(0xFFD8DED7)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFBF8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8DED7)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
          side: const BorderSide(color: ink),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: const Color(0xFFFAFBF8),
          foregroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    home: const GradientPage(),
  );
}

class GradientPage extends StatefulWidget {
  const GradientPage({super.key});
  @override
  State<GradientPage> createState() => _GradientPageState();
}

class _GradientPageState extends State<GradientPage> {
  List<Color> colors = List.of(palettes['Rainbow']!);
  String palette = 'Rainbow', format = 'Square';
  double angle = 45;
  bool radial = false, saving = false;
  String? error;
  final dimensions = const {
    'Square': (1080, 1080),
    'Wallpaper': (1920, 1080),
    'Story': (1080, 1920),
  };
  GradientArt get art =>
      GradientArt(List.of(colors), angle: angle, radial: radial);

  Future<void> editColor(int index) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (_) => ColorDialog(initial: colors[index]),
    );
    if (color != null && mounted) {
      setState(() {
        colors = List.of(colors)..[index] = color;
        palette = 'Custom';
      });
    }
  }

  Future<void> save(bool svg) async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final (w, h) = dimensions[format]!;
      final bytes = svg
          ? Uint8List.fromList(utf8.encode(art.svg(w, h)))
          : await art.png(w, h);
      final ext = svg ? 'svg' : 'png';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save your gradient',
        fileName: 'colorflow-${w}x$h.$ext',
        type: FileType.custom,
        allowedExtensions: [ext],
        bytes: bytes,
      );
      if (mounted && (path != null || kIsWeb)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb ? 'Download started.' : 'Gradient saved.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Couldn’t save. Please try again or choose another folder.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F2),
        image: DecorationImage(
          image: AssetImage('assets/sketchbook-background.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topLeft,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFECCDC7),
                            Color(0xFFF3E4CB),
                            Color(0xFFDCE8DC),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: accent,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'colorflow',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.8,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Text(
                  'Good colors. Great together.',
                  style: TextStyle(
                    fontSize: 34,
                    letterSpacing: -1.2,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Explore every color. Find your flow. Make something beautiful.',
                  style: TextStyle(fontSize: 14, height: 1.6, color: ink),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).width >= 1000 ? 76 : 26,
                ),
                LayoutBuilder(
                  builder: (context, box) => box.maxWidth < 780
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            preview(),
                            const SizedBox(height: 20),
                            controls(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: preview()),
                            const SizedBox(width: 24),
                            Expanded(flex: 4, child: controls()),
                          ],
                        ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Made on your device. No account, no uploads, no limits on ideas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget preview() {
    final (w, h) = dimensions[format]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomPaint(
          foregroundPainter: const CanvasTape(),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _studioCardDecoration,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_vintage_outlined,
                        size: 13,
                        color: accent,
                      ),
                      const SizedBox(width: 7),
                      const Expanded(
                        child: Text(
                          'LIVE CANVAS',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: .6,
                            color: muted,
                          ),
                        ),
                      ),
                      Text(
                        '$w × $h',
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                ),
                LayoutBuilder(
                  builder: (context, box) => Container(
                    height: (box.maxWidth * h / w).clamp(180.0, 660.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3ED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: w / h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Semantics(
                          label:
                              'Live ${radial ? 'radial' : 'linear'} gradient preview',
                          child: CustomPaint(
                            painter: ArtPainter(art),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          palette,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: ink,
                          ),
                        ),
                      ),
                      Text(
                        '${colors.length} colors · ${radial ? 'Radial' : '${angle.round()}°'}',
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'A LITTLE INSPIRATION',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: .5,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, box) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: palettes.entries
                .map(
                  (entry) => SizedBox(
                    width: (box.maxWidth - 24) / 3,
                    child: Column(
                      children: [
                        Semantics(
                          label: '${entry.key} palette',
                          button: true,
                          selected: palette == entry.key,
                          child: InkWell(
                            onTap: saving
                                ? null
                                : () => setState(() {
                                    colors = List.of(entry.value);
                                    palette = entry.key;
                                  }),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: box.maxWidth < 400 ? 64 : 94,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: GradientArt(
                                    entry.value,
                                  ).blendedColors,
                                ),
                                border: Border.all(
                                  color: palette == entry.key
                                      ? accent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: palette == entry.key
                                  ? const Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget controls() => Container(
    padding: const EdgeInsets.all(24),
    decoration: _studioCardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Make it yours',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -.5,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Every color is a new possibility.',
          style: TextStyle(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 20),
        const Divider(color: Color(0xFFE4E8E1), height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your colors',
                style: TextStyle(fontWeight: FontWeight.w600, color: ink),
              ),
            ),
            TextButton(
              onPressed: saving
                  ? null
                  : () => setState(() {
                      colors = colors.reversed.toList();
                      palette = 'Custom';
                    }),
              child: const Text('Reverse'),
            ),
          ],
        ),
        ...List.generate(
          colors.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: saving ? null : () => editColor(i),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: const BorderSide(color: Color(0xFFDDE3DB)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors[i],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            hex(colors[i]),
                            style: const TextStyle(fontSize: 13, color: ink),
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 15, color: muted),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove color ${i + 1}',
                  onPressed: saving || colors.length <= 2
                      ? null
                      : () => setState(() {
                          colors = List.of(colors)..removeAt(i);
                          palette = 'Custom';
                        }),
                  icon: const Icon(Icons.close, size: 17),
                ),
              ],
            ),
          ),
        ),
        TextButton.icon(
          onPressed: saving
              ? null
              : () => setState(() {
                  colors = [
                    ...colors,
                    HSVColor.fromAHSV(
                      1,
                      (colors.length * 137.5) % 360,
                      .7,
                      .95,
                    ).toColor(),
                  ];
                  palette = 'Custom';
                }),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add a color'),
        ),
        const SizedBox(height: 18),
        const Text(
          'Gradient style',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              icon: Icon(Icons.trending_flat),
              label: Text('Linear'),
            ),
            ButtonSegment(
              value: true,
              icon: Icon(Icons.radio_button_checked),
              label: Text('Radial'),
            ),
          ],
          selected: {radial},
          onSelectionChanged: saving
              ? null
              : (v) => setState(() => radial = v.first),
        ),
        if (!radial) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Direction',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
              ),
              Text(
                '${angle.round()}°',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
          Slider(
            value: angle,
            min: 0,
            max: 360,
            divisions: 72,
            label: '${angle.round()}°',
            onChanged: saving ? null : (v) => setState(() => angle = v),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Canvas size',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: format,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          items: dimensions.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    '${e.key}  ·  ${e.value.$1} × ${e.value.$2}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
          onChanged: saving ? null : (v) => setState(() => format = v!),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: saving ? null : () => save(false),
          icon: const Icon(Icons.download_rounded, size: 19),
          label: Text(saving ? 'Preparing…' : 'Download PNG'),
        ),
        TextButton(
          onPressed: saving ? null : () => save(true),
          child: const Text('Download SVG'),
        ),
        const Text(
          'Full resolution. No watermark.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: muted),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
          ),
      ],
    ),
  );
}

class ColorDialog extends StatefulWidget {
  const ColorDialog({super.key, required this.initial});
  final Color initial;
  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  late HSVColor hsv;
  late TextEditingController controller;
  String? error;
  @override
  void initState() {
    super.initState();
    hsv = HSVColor.fromColor(widget.initial);
    controller = TextEditingController(text: hex(widget.initial));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void update(HSVColor value) => setState(() {
    hsv = value;
    controller.text = hex(hsv.toColor());
    error = null;
  });
  void apply() {
    final value = controller.text.trim().replaceFirst('#', '');
    if (!_hexColorPattern.hasMatch(value)) {
      setState(() => error = 'Enter six hex digits, like B7CCFF.');
      return;
    }
    Navigator.pop(context, Color(int.parse('FF$value', radix: 16)));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Find your color'),
    content: SizedBox(
      width: 320,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: hsv.toColor(),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Hex color',
                errorText: error,
                border: const OutlineInputBorder(),
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(7)],
              onChanged: (text) {
                final value = text.replaceFirst('#', '');
                if (_hexColorPattern.hasMatch(value)) {
                  setState(() {
                    hsv = HSVColor.fromColor(
                      Color(int.parse('FF$value', radix: 16)),
                    );
                    error = null;
                  });
                }
              },
              onSubmitted: (_) => apply(),
            ),
            const SizedBox(height: 16),
            const Text('Hue'),
            Slider(
              value: hsv.hue,
              max: 360,
              onChanged: (v) => update(hsv.withHue(v)),
            ),
            const Text('Saturation'),
            Slider(
              value: hsv.saturation,
              onChanged: (v) => update(hsv.withSaturation(v)),
            ),
            const Text('Brightness'),
            Slider(
              value: hsv.value,
              onChanged: (v) => update(hsv.withValue(v)),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: apply, child: const Text('Use color')),
    ],
  );
}
