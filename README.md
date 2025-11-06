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
  - Custom Colors & Decorations
  - Adjustable Size & Padding
  - Custom Widgets as Content
  - Triangle Pointer Styling

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

## Installation

Add Widget Tooltip to your `pubspec.yaml`:

```yaml
dependencies:
  widget_tooltip: ^1.1.3
```

Or run:

```bash
flutter pub add widget_tooltip
```

## Quick Start

### Basic Usage

```dart
import 'package:widget_tooltip/widget_tooltip.dart';

WidgetTooltip(
  message: Text('Hello World!'),
  child: Icon(Icons.info),
)
```

### Customized Tooltip

```dart
WidgetTooltip(
  message: Text(
    'Styled tooltip',
    style: TextStyle(color: Colors.white),
  ),
  child: Icon(Icons.help),
  triggerMode: WidgetTooltipTriggerMode.tap,
  direction: WidgetTooltipDirection.top,
  triangleColor: Colors.blue,
  messageDecoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
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

### Manual Control

```dart
final TooltipController controller = TooltipController();

WidgetTooltip(
  controller: controller,
  triggerMode: WidgetTooltipTriggerMode.manual,
  dismissMode: WidgetTooltipDismissMode.manual,
  message: Text('Controlled tooltip'),
  child: IconButton(
    icon: Icon(Icons.info),
    onPressed: controller.show,
  ),
)

// Show programmatically
controller.show();

// Dismiss programmatically
controller.dismiss();

// Toggle visibility
controller.toggle();
```

## API Reference

### WidgetTooltip Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `message` | `Widget` | **required** | The widget to display inside the tooltip |
| `child` | `Widget` | **required** | The target widget that triggers the tooltip |
| `controller` | `TooltipController?` | `null` | Optional controller for programmatic control |
| `triggerMode` | `WidgetTooltipTriggerMode?` | `longPress` | How the tooltip is triggered |
| `dismissMode` | `WidgetTooltipDismissMode?` | `tapAnyWhere` | How the tooltip is dismissed |
| `direction` | `WidgetTooltipDirection?` | `null` | Preferred direction (auto if null) |
| `axis` | `Axis` | `Axis.vertical` | Positioning axis |
| `messageDecoration` | `BoxDecoration` | Black with rounded corners | Decoration for the message container |
| `messagePadding` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(vertical: 8, horizontal: 16)` | Padding inside the message container |
| `messageStyle` | `TextStyle?` | White, 14px | Text style for the message |
| `triangleColor` | `Color` | `Colors.black` | Color of the pointer triangle |
| `triangleSize` | `Size` | `Size(10, 10)` | Size of the pointer triangle |
| `triangleRadius` | `double` | `2` | Radius of the triangle's rounded tip |
| `targetPadding` | `double` | `4` | Gap between target and tooltip |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | Screen edge padding |
| `offsetIgnore` | `bool` | `false` | Disable automatic position adjustment |
| `onShow` | `VoidCallback?` | `null` | Callback when tooltip is shown |
| `onDismiss` | `VoidCallback?` | `null` | Callback when tooltip is dismissed |

### Enums

#### WidgetTooltipTriggerMode

- `tap` - Show on single tap
- `longPress` - Show on long press (default)
- `doubleTap` - Show on double tap
- `manual` - Show only via controller

#### WidgetTooltipDismissMode

- `tapOutside` - Dismiss when tapping outside
- `tapAnyWhere` - Dismiss when tapping anywhere (default)
- `tapInside` - Dismiss when tapping inside
- `manual` - Dismiss only via controller

#### WidgetTooltipDirection

- `top` - Position above the target
- `bottom` - Position below the target
- `left` - Position to the left
- `right` - Position to the right

### TooltipController

```dart
class TooltipController extends ChangeNotifier {
  bool get isShow; // Check if tooltip is visible
  void show();     // Show the tooltip
  void dismiss();  // Hide the tooltip
  void toggle();   // Toggle visibility
}
```

## Examples

### Different Trigger Modes

```dart
// Tap to show
WidgetTooltip(
  triggerMode: WidgetTooltipTriggerMode.tap,
  message: Text('Tap trigger'),
  child: Icon(Icons.touch_app),
)

// Long press to show (default)
WidgetTooltip(
  triggerMode: WidgetTooltipTriggerMode.longPress,
  message: Text('Long press trigger'),
  child: Icon(Icons.touch_app),
)

// Double tap to show
WidgetTooltip(
  triggerMode: WidgetTooltipTriggerMode.doubleTap,
  message: Text('Double tap trigger'),
  child: Icon(Icons.touch_app),
)
```

### Different Dismiss Modes

```dart
// Tap outside to dismiss
WidgetTooltip(
  dismissMode: WidgetTooltipDismissMode.tapOutside,
  message: Text('Tap outside to dismiss'),
  child: Icon(Icons.info),
)

// Tap anywhere to dismiss (default)
WidgetTooltip(
  dismissMode: WidgetTooltipDismissMode.tapAnyWhere,
  message: Text('Tap anywhere to dismiss'),
  child: Icon(Icons.info),
)

// Tap inside to dismiss
WidgetTooltip(
  dismissMode: WidgetTooltipDismissMode.tapInside,
  message: Text('Tap inside to dismiss'),
  child: Icon(Icons.info),
)
```

### Custom Styling

```dart
WidgetTooltip(
  message: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: Colors.amber),
      SizedBox(width: 8),
      Text('Custom content!'),
    ],
  ),
  triangleColor: Colors.purple,
  triangleSize: Size(12, 12),
  messageDecoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.purple, Colors.deepPurple],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  messagePadding: EdgeInsets.all(20),
  child: Icon(Icons.info),
)
```

### With Callbacks

```dart
WidgetTooltip(
  message: Text('Tooltip with callbacks'),
  child: Icon(Icons.info),
  onShow: () => print('Tooltip shown'),
  onDismiss: () => print('Tooltip dismissed'),
)
```

## Platform Support

| Platform | Support |
|----------|---------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

## Requirements

- Flutter SDK: `>=3.2.5`
- Dart SDK: `>=3.2.5 <4.0.0`

## Why Widget Tooltip?

Flutter's built-in Tooltip widget is great for simple use cases, but when you need more control over the appearance and behavior of your tooltips, Widget Tooltip provides:

- **Rich Customization**: Full control over the tooltip's appearance, including custom widgets as content
- **Smart Positioning**: Automatically adjusts position to stay within screen bounds
- **Multiple Triggers**: Choose from various trigger modes or implement manual control
- **Flexible Dismiss Behavior**: Configure how tooltips are dismissed based on your needs
- **Controller Support**: Programmatically control tooltip visibility
- **Callback Support**: React to tooltip show/hide events
- **Well Documented**: Comprehensive API documentation and examples

## Documentation

For detailed documentation and examples, visit our [documentation site](https://hongmono.github.io/widget_tooltip).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created and maintained by [hongmono](https://github.com/hongmono).
