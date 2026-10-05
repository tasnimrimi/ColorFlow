import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gradient_art.dart';

const ink = Color(0xFF272439),
    muted = Color(0xFF7D798D),
    accent = Color(0xFF7059D9);
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
      scaffoldBackgroundColor: const Color(0xFFF8F7FB),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        surface: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFA4B5FF),
                          Color(0xFFCA98E6),
                          Color(0xFFFFBC9D),
                        ],
                      ),
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
                  const Text(
                    'YOUR LITTLE COLOR STUDIO',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: muted,
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
                style: TextStyle(fontSize: 14, height: 1.6, color: muted),
              ),
              const SizedBox(height: 26),
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
  );

  Widget preview() {
    final (w, h) = dimensions[format]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E5EF)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 7, color: Color(0xFF91BDA1)),
                    const SizedBox(width: 7),
                    const Text(
                      'LIVE CANVAS',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: muted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$w × $h',
                      style: const TextStyle(fontSize: 11, color: muted),
                    ),
                  ],
                ),
              ),
              Container(
                height: 400,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0F6),
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
        const SizedBox(height: 24),
        const Text(
          'A LITTLE INSPIRATION',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: palettes.entries
              .map(
                (entry) => SizedBox(
                  width: 96,
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
                            height: 58,
                        width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(colors: entry.value),
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
      ],
    );
  }

  Widget controls() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE8E5EF)),
    ),
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
        const SizedBox(height: 24),
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
                      side: const BorderSide(color: Color(0xFFE8E5EF)),
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
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
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
                if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value)) {
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
