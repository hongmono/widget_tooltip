## 1.2.2

### Bug Fixes
* **direction in ListView**: Fix `direction` parameter being ignored inside `ListView` and other scrollable widgets ([#7](https://github.com/hongmono/widget_tooltip/issues/7))
* **tooltip positioning**: Fix tooltip appearing near screen center instead of target due to incorrect measurement constraints
* **scale animation**: Fix scale animation not working — now triangle and message box animate as a unified element

### Improvements
* **Two-phase positioning**: Restore proven measure-then-position approach for reliable tooltip placement
* **Combined tooltip element**: Triangle and message box are now a single composite widget, ensuring consistent animation behavior
* **ListView example**: Add ListView tab to example app for testing scroll scenarios

## 1.2.1

### Improvements
* **Unified tooltip widget**: Merge triangle and message box into a single widget for smoother animations
* **Better scale animation**: Scale animation now expands from a single center point instead of separately
* **Code simplification**: Remove `triangleOffset` calculation and `kTriangleOverlapOffset` constant

## 1.2.0

### Features
* **autoFlip**: Add `autoFlip` property to automatically flip tooltip direction when there's not enough space at screen edges
* **hover**: Add `WidgetTooltipTriggerMode.hover` for Desktop/Web mouse hover support

### Breaking Changes
* **messageStyle removed**: Remove unused `messageStyle` property

### Deprecations
* **tapAnyWhere**: Deprecate `WidgetTooltipDismissMode.tapAnyWhere` in favor of `tapAnywhere` (correct spelling)

### Bug Fixes
* **autoFlip**: Simplified logic - now uses screen center to determine tooltip position (target in top half → tooltip below, target in bottom half → tooltip above)
* **visibility**: Auto-dismiss tooltip when target scrolls off-screen

### Improvements
* Add comprehensive documentation for `TooltipController` and `WidgetTooltip` classes
* Refactor internal variable names for better code readability
* Remove unused `isLeft`/`isRight` parameters from internal `_TooltipOverlay` widget
* Improve example app with better styling and demonstrations

## 1.1.4
* *Bug fixed*: Fix right padding not working when text is long

## 1.1.3

### Features
* **Documentation**: Improve documentation and examples.

## 1.1.2

### Features
* **Performance**: Improve performance and stability.

## 1.1.1

### Features
* **Bug fixes**: Fix minor bugs and improve stability.

## 1.1.0

### Features
* **triangleRadius**: Add new property to set the radius of the triangle.

## 1.0.0

### Features
* **Widget Tooltip**: Add new widget to display a tooltip.
