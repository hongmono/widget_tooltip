# Widget Tooltip

A highly customizable tooltip widget for Flutter applications that provides rich functionality for displaying tooltips with various trigger modes, dismiss behaviors, and styling options.

[![pub package](https://img.shields.io/pub/v/widget_tooltip.svg)](https://pub.dev/packages/widget_tooltip)
[![likes](https://img.shields.io/pub/likes/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![popularity](https://img.shields.io/pub/popularity/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![pub points](https://img.shields.io/pub/points/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)

## Features

- 🎯 **Multiple Trigger Modes**

  - Tap
  - Long Press
  - Double Tap
  - Manual Control

- 🎨 **Customizable Appearance**

  - Custom Colors
  - Adjustable Size
  - Flexible Styling
  - Custom Decorations

- 📍 **Smart Positioning**

  - Automatic Edge Detection
  - Multiple Directions (Top, Bottom, Left, Right)
  - Customizable Padding and Offset
  - Axis Control (Vertical/Horizontal)

- 🎮 **Flexible Control**

  - Built-in Controller
  - Show/Hide Callbacks
  - Custom Dismiss Behaviors
  - Event Handling

- 🎬 **Animation Types**

  - Fade (default)
  - Scale
  - Scale & Fade
  - No Animation

- ⏱️ **Auto Dismiss**
  - Configurable Auto-dismiss Duration
  - Custom Animation Duration

## Installation

Add Widget Tooltip to your `pubspec.yaml`:

```yaml
dependencies:
  widget_tooltip: ^1.0.0 # Replace with the latest version
```

Or run:

```bash
flutter pub add widget_tooltip
```

## Usage

```dart
import 'package:widget_tooltip/widget_tooltip.dart';

// Basic usage
WidgetTooltip(
  message: Text('Hello World!'),
  child: Icon(Icons.info),
)

// With animation and auto-dismiss
WidgetTooltip(
  message: Text('I will disappear in 3 seconds!'),
  child: Icon(Icons.help),
  triggerMode: WidgetTooltipTriggerMode.tap,
  animation: WidgetTooltipAnimation.scaleAndFade,
  autoDismissDuration: Duration(seconds: 3),
  animationDuration: Duration(milliseconds: 200),
)

// Customized tooltip
WidgetTooltip(
  message: Text(
    'Styled tooltip',
    style: TextStyle(color: Colors.white),
  ),
  child: Icon(Icons.help),
  triggerMode: WidgetTooltipTriggerMode.tap,
  direction: WidgetTooltipDirection.top,
  animation: WidgetTooltipAnimation.scale,
  messageDecoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  messagePadding: EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  ),
)
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0

## Why Widget Tooltip?

Flutter's built-in Tooltip widget is great for simple use cases, but when you need more control over the appearance and behavior of your tooltips, Widget Tooltip provides:

- **Rich Customization**: Full control over the tooltip's appearance, including custom widgets as content
- **Smart Positioning**: Automatically adjusts position to stay within screen bounds
- **Multiple Triggers**: Choose from various trigger modes or implement manual control
- **Flexible Dismiss Behavior**: Configure how tooltips are dismissed based on your needs
- **Controller Support**: Programmatically control tooltip visibility
- **Callback Support**: React to tooltip show/hide events

## Documentation

For detailed documentation and examples, visit our [documentation site](https://hongmono.github.io/widget_tooltip).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
