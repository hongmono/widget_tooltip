# Flutter Packages

A monorepo for Flutter packages by [hongmono](https://github.com/hongmono).

## Packages

| Package | Version | Description |
|---|---|---|
| [widget_tooltip](packages/widget_tooltip/) | [![pub](https://img.shields.io/pub/v/widget_tooltip.svg)](https://pub.dev/packages/widget_tooltip) | A highly customizable tooltip widget for Flutter |
| [burst_icon_button](packages/burst_icon_button/) | [![pub](https://img.shields.io/pub/v/burst_icon_button.svg)](https://pub.dev/packages/burst_icon_button) | Icon button with burst animation on tap/long-press |
| [floating_widget](packages/floating_widget/) | — | A draggable floating widget with boundary constraints |

## Getting Started

This project uses [Melos](https://melos.invertase.dev/) with [Dart pub workspaces](https://dart.dev/tools/pub/workspaces).

### Setup

```bash
# Install Melos globally
dart pub global activate melos

# Install dependencies
flutter pub get

# Bootstrap workspace
melos bootstrap
```

### Commands

```bash
# Run analysis on all packages
melos run analyze

# Run tests on all packages
melos run test

# Format all code
melos run format
```

## Example App

```bash
cd apps/example
flutter run
```

## License

See individual packages for their licenses.
