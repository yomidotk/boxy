# Boxy - Flutter UI Layout Builder

## Overview
Boxy is a Flutter web application for building UI layouts visually. It's a drag-and-drop UI designer that allows creating layouts with various components (boxes, buttons, text, images, cards, etc.) and exporting them.

## Architecture
- **Framework**: Flutter 3.32.0 (Dart 3.8.0)
- **Platform**: Web (built with flutter build web)
- **State Management**: Provider pattern (`provider` package)
- **Rendering**: CanvasKit (WASM-based renderer)

## Project Structure
```
lib/
  main.dart           - App entry point
  models/             - Data models (LayoutItem, ThemePalette)
  painters/           - Custom painters (BlueprintPainter)
  providers/          - State management (LayoutProvider)
  screens/            - UI screens (MainScreen, SplashScreen)
  utils/              - Utilities (CodeGenerator, Exporter, HtmlGenerator)
  widgets/            - UI components (DesignCanvas, ToolSidebar, PropertiesPanel, etc.)
web/                  - Web-specific files (index.html, manifest.json, icons)
assets/               - App assets (logo.png, app_icon.png)
build/web/            - Built web output (served by server.js)
```

## Running Locally
The app is built and served statically:
1. Build: `flutter build web --release --pwa-strategy none --no-web-resources-cdn`
2. Serve: `node server.js` (serves build/web/ on port 5000)

## Key Dependencies
- `provider: ^6.1.5` - State management
- `gal: ^2.3.2` - Image gallery saving
- `cupertino_icons: ^1.0.8` - iOS-style icons

## Development Notes
- SDK constraint updated from `^3.10.4` to `^3.8.0` to match Flutter's bundled Dart version
- Flutter 3.32.0 from Nix uses Dart 3.8.0 internally (despite standalone Dart 3.10.4 being present)
- Service worker is disabled (`--pwa-strategy none`) for Replit compatibility
- CDN resources are bundled locally (`--no-web-resources-cdn`) for offline/iframe serving
- CanvasKit WASM (~7MB) handles rendering; initial load may take a few seconds

## Workflow
- **Start application**: `node server.js` on port 5000 (webview)

## Deployment
- Type: Static site
- Build command: `flutter build web --release`
- Public directory: `build/web`
