# Apple Music Clone for Android 🎵

A pixel-perfect Apple Music iOS-style local music player built with Flutter, targeting Android.

## Features

- 🎨 **Dynamic Liquid Glass UI** — blurred, color-extracted backgrounds from album art
- 🎵 **Full local library** — reads music files via `on_audio_query`
- 🌀 **Rotating album art** — spins while playing, pauses when stopped
- 🔍 **Search** — instant search across songs, artists, and albums
- 🔀 **Shuffle & Repeat** — all three repeat modes
- ❤️ **Like/heart** songs inline
- 📱 **Mini player** — frosted glass bar above the nav bar
- 🎛 **Volume control** — in-player volume slider
- 📂 **Library** — Songs, Albums, Artists, Playlists tabs

## Screenshots

> Build the APK and install it on your device to see the full experience.

## Getting Started

### Prerequisites

- [Flutter SDK ≥ 3.24.0](https://flutter.dev/docs/get-started/install)
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Run locally

```bash
git clone https://github.com/YOUR_USERNAME/apple_music_flutter.git
cd apple_music_flutter
flutter pub get
flutter run
```

### Build APK

```bash
# Split APKs (smaller, optimized per device)
flutter build apk --release --split-per-abi

# Universal APK (works on all devices)
flutter build apk --release
```

APKs are placed in `build/app/outputs/flutter-apk/`.

## Download

Head to the **[Releases](../../releases)** page and download the APK for your device:

| APK | Best For |
|-----|----------|
| `app-arm64-v8a-release.apk` | Most modern Android phones (recommended) |
| `app-release.apk` | Universal — works on any Android device |

## Permissions

| Permission | Reason |
|-----------|--------|
| `READ_MEDIA_AUDIO` | Read music files on Android 13+ |
| `READ_EXTERNAL_STORAGE` | Read music files on Android ≤ 12 |
| `FOREGROUND_SERVICE` | Background audio playback |
| `WAKE_LOCK` | Keep playback alive when screen is off |

## Tech Stack

| Package | Purpose |
|---------|---------|
| `just_audio` | Audio playback engine |
| `on_audio_query` | Query device music library |
| `palette_generator` | Extract colors from album art |
| `provider` | State management |
| `glassmorphism` | Frosted glass UI effects |
| `marquee` | Scrolling song title text |
| `rxdart` | Stream combining for position data |
| `permission_handler` | Runtime permission requests |
| `audio_session` | Audio focus management |

## CI/CD

GitHub Actions automatically builds and releases APKs on every push to `main`.  
See [`.github/workflows/build-apk.yml`](.github/workflows/build-apk.yml).

## License

MIT — feel free to fork and customize.
