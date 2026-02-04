## 0.1.0

### Features
* **snapToEdge**: Animate to nearest horizontal edge when released
* **initialAlignment**: `FloatingAlignment` enum with 9 positions (topLeft through bottomRight)
* **onPositionChanged**: Callback fired after drag ends
* **Smooth animation**: Configurable snap animation duration and curve

### Bug Fixes
* **Null safety**: Fix force cast on `findRenderObject()` with safe `is RenderBox` check
* **Late init**: Change `_floatingWidgetSize` to nullable with proper guards
* **mounted check**: Add `mounted` guard before `setState` calls
* **Drag behavior**: Replace `Draggable` with `GestureDetector` for proper pan handling

### Improvements
* Add comprehensive doc comments to all public API members
* Add 9 unit tests
* Migrate to `flutter-packages` monorepo

## 0.0.1

* Initial release from `flutter_interactions` repository
