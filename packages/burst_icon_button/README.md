# BurstIconButton

A customizable Flutter widget that creates a burst animation effect when an icon button is tapped or long-pressed. Perfect for adding engaging, playful micro-interactions to your app.

![Screenshot placeholder](https://via.placeholder.com/400x200?text=BurstIconButton+Demo)

## Features

- 🎯 **Tap burst** — spawns animated icons that float up and fade out
- 🔁 **Long-press burst** — continuously spawns icons while held
- 🎨 **Customizable icons** — separate icons for default, pressed, and burst states
- ⏱️ **Adjustable timing** — control animation duration and long-press throttle
- 🌊 **Configurable motion** — set horizontal sway, vertical distance, and animation curve
- 💥 **Burst count** — spawn multiple icons per tap for a dramatic effect

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  burst_icon_button: ^0.1.38
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic

```dart
import 'package:burst_icon_button/burst_icon_button.dart';

BurstIconButton(
  icon: const Icon(Icons.favorite_border, size: 32),
  onPressed: () {
    print('Pressed!');
  },
)
```

### Custom Icons

Use different icons for the default, pressed, and burst states:

```dart
BurstIconButton(
  icon: const Icon(Icons.favorite_border, size: 48, color: Colors.grey),
  pressedIcon: const Icon(Icons.favorite, size: 48, color: Colors.red),
  burstIcon: const Icon(Icons.favorite, size: 48, color: Colors.pink),
  onPressed: () {},
)
```

### Long Press with Continuous Burst

Long-pressing spawns icons continuously at the `throttleDuration` interval:

```dart
BurstIconButton(
  icon: const Icon(Icons.star_border, size: 48),
  burstIcon: const Icon(Icons.star, size: 48, color: Colors.amber),
  throttleDuration: const Duration(milliseconds: 80),
  onPressed: () {},
)
```

### Dramatic Multi-Burst

Spawn multiple icons per tap and customize the motion:

```dart
BurstIconButton(
  icon: const Icon(Icons.local_fire_department, size: 48, color: Colors.orange),
  burstIcon: const Icon(Icons.local_fire_department, size: 48, color: Colors.deepOrange),
  burstCount: 3,
  crossAmplitude: 30.0,
  burstDistance: 150.0,
  burstCurve: Curves.easeOutCubic,
  duration: const Duration(milliseconds: 1500),
  onPressed: () {},
)
```

## API Reference

| Property | Type | Default | Description |
|---|---|---|---|
| `icon` | `Icon` | **required** | The default icon displayed in the button. |
| `pressedIcon` | `Icon?` | `null` | Icon shown while the button is pressed. Falls back to `icon`. |
| `burstIcon` | `Icon?` | `null` | Icon used for the burst animation. Falls back to `icon`. |
| `onPressed` | `VoidCallback?` | **required** | Callback when the button is tapped or long-press ends. |
| `duration` | `Duration` | `1200ms` | Duration of the burst float-up animation. |
| `throttleDuration` | `Duration` | `100ms` | Interval between burst spawns during long press. |
| `crossAmplitude` | `double?` | `10.0` | Max horizontal sway (in logical pixels) of burst icons. |
| `burstDistance` | `double?` | `100.0` | Vertical distance (in logical pixels) burst icons travel. |
| `burstCount` | `int?` | `1` | Number of burst icons spawned per tap. |
| `burstCurve` | `Curve?` | `Curves.easeOut` | Animation curve for the burst effect. |

## License

This package is distributed under the MIT License. See [LICENSE](LICENSE) for details.
