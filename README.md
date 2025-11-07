# Widget Tooltip

> **English** | [한국어](README.ko.md)

A highly customizable tooltip widget for Flutter applications that provides rich functionality for displaying tooltips with various trigger modes, dismiss behaviors, and styling options.

[![pub package](https://img.shields.io/pub/v/widget_tooltip.svg)](https://pub.dev/packages/widget_tooltip)
[![likes](https://img.shields.io/pub/likes/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![popularity](https://img.shields.io/pub/popularity/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)
[![pub points](https://img.shields.io/pub/points/widget_tooltip)](https://pub.dev/packages/widget_tooltip/score)

![Widget Tooltip Demo](assets/demo.gif)

## ✨ Features

### 🎯 Multiple Trigger Modes
- **Tap**: Show tooltip on single tap
- **Long Press**: Show tooltip on long press (default)
- **Double Tap**: Show tooltip on double tap
- **Manual**: Programmatic control via controller

### 🎨 Full Customization
- ✅ Custom colors
- ✅ Adjustable sizes
- ✅ Flexible styling
- ✅ Custom decorations
- ✅ Any widget as message content
- ✅ Customizable triangle pointer

### 📍 Smart Positioning
- 🔄 Automatic edge detection and adjustment
- 🧭 Four directions (top, bottom, left, right)
- 📏 Customizable padding and offset
- 🎚️ Axis control (vertical/horizontal)
- 🖥️ Automatic viewport boundary detection

### 🎮 Flexible Control
- 🎛️ Built-in controller support
- 📣 Show/hide callbacks
- 🚪 Custom dismiss behaviors
  - Tap outside tooltip
  - Tap inside tooltip
  - Tap anywhere
  - Manual control
- 🔔 Event handling

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  widget_tooltip: ^1.1.4
```

Or run this command:

```bash
flutter pub add widget_tooltip
```

## 🚀 Usage

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
    style: TextStyle(color: Colors.white, fontSize: 16),
  ),
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Button'),
  ),
  // Trigger configuration
  triggerMode: WidgetTooltipTriggerMode.tap,

  // Direction
  direction: WidgetTooltipDirection.top,

  // Styling
  triangleColor: Colors.blue,
  messageDecoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  messagePadding: EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  ),

  // Triangle pointer configuration
  triangleSize: Size(12, 12),
  triangleRadius: 2,
  targetPadding: 8,
)
```

### Manual Control with Controller

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TooltipController _controller = TooltipController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WidgetTooltip(
          message: Text('Controlled tooltip'),
          controller: _controller,
          dismissMode: WidgetTooltipDismissMode.manual,
          child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Text('Target Widget'),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _controller.show,
              child: Text('Show'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _controller.dismiss,
              child: Text('Hide'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _controller.toggle,
              child: Text('Toggle'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### Using Callbacks

```dart
WidgetTooltip(
  message: Text('Tooltip with callbacks'),
  child: Icon(Icons.help),
  onShow: () {
    print('Tooltip shown');
  },
  onDismiss: () {
    print('Tooltip dismissed');
  },
)
```

### Long Text Handling

```dart
WidgetTooltip(
  message: Text(
    'Even very long text is automatically adjusted to fit the screen size. '
    'Widget Tooltip ensures tooltips always stay within screen boundaries '
    'with smart edge detection.',
    style: TextStyle(color: Colors.white),
  ),
  child: Icon(Icons.article),
  messageDecoration: BoxDecoration(
    color: Colors.black87,
    borderRadius: BorderRadius.circular(8),
  ),
  messagePadding: EdgeInsets.all(16),
)
```

## 🎯 Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `message` | `Widget` | **Required** | Widget to display in tooltip |
| `child` | `Widget` | **Required** | Target widget |
| `triggerMode` | `WidgetTooltipTriggerMode?` | `longPress` | Tooltip trigger mode |
| `dismissMode` | `WidgetTooltipDismissMode?` | `tapAnyWhere` | Tooltip dismiss mode |
| `direction` | `WidgetTooltipDirection?` | `null` (auto) | Tooltip display direction |
| `axis` | `Axis` | `vertical` | Layout axis |
| `controller` | `TooltipController?` | `null` | Controller for manual control |
| `triangleColor` | `Color` | `Colors.black` | Triangle pointer color |
| `triangleSize` | `Size` | `Size(10, 10)` | Triangle pointer size |
| `triangleRadius` | `double` | `2` | Triangle pointer corner radius |
| `targetPadding` | `double` | `4` | Gap between target and tooltip |
| `messageDecoration` | `BoxDecoration` | Black background, rounded corners | Message box decoration |
| `messagePadding` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(vertical: 8, horizontal: 16)` | Message box padding |
| `messageStyle` | `TextStyle?` | White text, 14px | Message text style |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | Padding from screen edges |
| `offsetIgnore` | `bool` | `false` | Whether to ignore offset |
| `onShow` | `VoidCallback?` | `null` | Callback when tooltip shows |
| `onDismiss` | `VoidCallback?` | `null` | Callback when tooltip dismisses |

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| ✅ Android | Supported |
| ✅ iOS | Supported |
| ✅ Web | Supported |
| ✅ Windows | Supported |
| ✅ macOS | Supported |
| ✅ Linux | Supported |

## 🔧 Requirements

- **Flutter SDK**: >=1.17.0
- **Dart SDK**: >=3.2.5 <4.0.0

## 💡 Why Widget Tooltip?

Flutter's built-in `Tooltip` widget is great for simple use cases, but when you need more control over the appearance and behavior of your tooltips, Widget Tooltip provides:

| Feature | Flutter's Tooltip | Widget Tooltip |
|---------|-------------------|----------------|
| Custom widget message | ❌ (Text only) | ✅ Any widget |
| Trigger mode selection | ❌ | ✅ 4 modes |
| Dismiss behavior control | ❌ | ✅ 4 options |
| Programmatic control | Limited | ✅ Full control |
| Triangle pointer | ❌ | ✅ Customizable |
| Edge detection | Basic | ✅ Smart detection |
| Callback support | ❌ | ✅ onShow, onDismiss |

## 📚 Documentation

For detailed documentation and examples, visit our [documentation site](https://hongmono.github.io/widget_tooltip).

### Documentation Sections
- 📖 [Installation Guide](https://hongmono.github.io/widget_tooltip/installation)
- 🎓 [Basic Usage](https://hongmono.github.io/widget_tooltip/basic-usage)
- 🚀 [Advanced Usage](https://hongmono.github.io/widget_tooltip/advanced-usage)
- 🎨 [Styling Examples](https://hongmono.github.io/widget_tooltip/examples/styling)
- 🎯 [Trigger Modes](https://hongmono.github.io/widget_tooltip/examples/trigger-modes)
- 🚪 [Dismiss Modes](https://hongmono.github.io/widget_tooltip/examples/dismiss-modes)
- 📍 [Positioning](https://hongmono.github.io/widget_tooltip/examples/positioning)

## 🤝 Contributing

Contributions are always welcome! Please feel free to submit a Pull Request or report issues.

1. Fork this repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**hongmono**
- GitHub: [@hongmono](https://github.com/hongmono)
- Package: [pub.dev/publishers/hongmono.com](https://pub.dev/publishers/hongmono.com/packages)

## 🌟 Show Your Support

Give a ⭐️ if this project helped you!

---

**Version**: 1.1.4
**Last Updated**: 2025
