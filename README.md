# Colorflow

A Flutter gradient-background maker. Pick any colors using hex values or
hue/saturation/brightness sliders. Changes appear immediately on the canvas.

- Linear gradients with adjustable direction, or centered radial gradients.
- Full rainbow preset and five other starting palettes; add/remove/reverse colors with no fixed stop-count limit.
- Square (1080 × 1080), wallpaper (1920 × 1080), and story (1080 × 1920).
- Full-size PNG and genuine vector SVG exports, with no watermark.
- Runs on-device, without AI, accounts, or photo uploads.

Open the project in Android Studio and run `lib/main.dart`, or use:

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Native exports use the system save dialog; browsers download the file. The app
does not persist unfinished gradients between sessions. The Dart package name
and application identifiers remain unchanged to preserve the existing project.
