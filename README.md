<div align="center">

# 🌈 Colorflow

### A colorful gradient-background studio built with Flutter

![Flutter](https://img.shields.io/badge/Flutter-UI-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Exports](https://img.shields.io/badge/Export-PNG_%26_SVG-7059D9?style=for-the-badge)
![Local](https://img.shields.io/badge/Processing-On_Device-22C55E?style=for-the-badge)

**Explore every color · Blend smoothly · Create your own background**

</div>

## About

Colorflow turns user-selected colors into smooth gradient backgrounds. Start with
a rainbow or another preset, customize the palette, and watch the canvas update
live. Download the result as a full-resolution PNG or a scalable vector SVG.

Everything is generated on the device. No AI service, account, API key, or photo
upload is required.

> The repository keeps its original name, `Photo-into-Blank-Mockup`, but the
> current application is **Colorflow**, a gradient maker.

## Features

- Full rainbow preset, plus Daydream, Afterglow, Lagoon, Sorbet, and Midnight
- Full-spectrum hue, saturation, and brightness controls
- Custom colors through six-digit hex values
- Add colors without a fixed count limit; keep at least two in the palette
- Remove individual colors or reverse the whole palette
- Smooth color blending instead of separate, sharply joined color ramps
- Linear gradients with adjustable direction, or centered radial gradients
- Live preview with responsive phone and desktop layouts
- Full-resolution PNG and genuine vector SVG downloads
- No watermark, account, or server-side processing

## Canvas Sizes

| Format | Resolution | Suitable for |
|---|---|---|
| Square | 1080 × 1080 | Square graphics and backgrounds |
| Wallpaper | 1920 × 1080 | Desktop backgrounds and landscape layouts |
| Story | 1080 × 1920 | Vertical backgrounds and story layouts |

## How It Works

1. Start with the rainbow or choose another palette.
2. Click a color to adjust it using sliders or a hex value.
3. Add, remove, or reverse colors to shape the palette.
4. Choose Linear or Radial and adjust the direction for a linear gradient.
5. Pick a canvas size and download PNG or SVG.

The palette is blended along a continuous Bézier color curve, sampled at 257
positions. This softens the transition between neighboring colors. Middle colors
influence the mixture rather than appearing as solid bands. The preview and both
export formats use the same blended palette and gradient geometry.

## Technology Stack

| Layer | Technology |
|---|---|
| Interface | Flutter and Material 3 |
| Language | Dart |
| Rendering | Flutter Canvas and `dart:ui` gradient shaders |
| Color blending | Bézier curve with Bernstein weights |
| PNG export | Canvas rendering and PNG encoding |
| SVG export | Vector gradient markup generated in Dart |
| Save dialog / download | `file_picker` |
| Verification | Flutter widget and rendering tests |

## Run Locally

### Requirements

- Flutter SDK compatible with Dart 3.8.1 or later in the Dart 3 series
- Git
- Chrome for the browser version, or Android Studio and an Android device/emulator

### Clone and install

```powershell
git clone https://github.com/tasnimrimi/Photo-into-Blank-Mockup.git
cd Photo-into-Blank-Mockup
flutter pub get
```

### Run in Chrome

```powershell
flutter run -d chrome
```

### Run on Android

Open the project root in Android Studio, select an Android device or emulator,
and run `lib/main.dart`. Alternatively:

```powershell
flutter run
```

On Windows, Flutter plugin setup may require Developer Mode for symbolic links.

## Automated Tests

The project contains five tests covering:

- Smooth palette blending and long palettes
- Adding colors beyond the seven-color rainbow
- Phone layout and hex-color validation
- SVG gradient stops and vector geometry
- PNG output dimensions and rendered colors

```powershell
flutter analyze
flutter test
```

## Build for the Web

```powershell
flutter build web
```

The generated browser application is written to `build/web`.

## Key Files

```text
lib/
├── main.dart              # Interface, color picker, palettes, and save flow
└── gradient_art.dart      # Smooth blending, canvas rendering, PNG/SVG export
test/
└── widget_test.dart       # Color controls, blending, layout, and export tests
web/                      # Browser app shell and manifest
android/                  # Android platform project
pubspec.yaml              # Dependencies and Flutter configuration
```

## Current Notes

- Unfinished gradients are kept in memory and are not saved between sessions.
- Browser exports download a file; native platforms use the system save dialog.
- Other platform folders are included, but full device testing across every
  platform has not been completed.
- The original Dart package name and application identifiers are retained.

## Author

**Tasnim Akhter** · [GitHub](https://github.com/tasnimrimi)

---

<div align="center">

Good colors. Great together. 🌈

</div>
