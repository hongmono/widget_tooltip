## 0.2.0

### Features
* **burstCount**: Spawn multiple burst icons per tap (default 1)
* **burstDistance**: Configurable vertical travel distance (default 100.0)
* **burstCurve**: Custom animation curve (default `Curves.easeOut`)

### Bug Fixes
* **Timer disposal**: Fix timer not being cancelled in `dispose()`
* **Controller disposal**: Fix animation controllers in `_icons` list not being disposed on widget dispose
* **WidgetState**: Replace deprecated `WidgetState` with simple boolean
* **mounted check**: Add `mounted` guard before `setState` in animation listener

### Improvements
* Add comprehensive doc comments to all public API members
* Add 11 unit tests
* Migrate to `flutter-packages` monorepo

## 0.1.38

* Previous release from `flutter_interactions` repository
