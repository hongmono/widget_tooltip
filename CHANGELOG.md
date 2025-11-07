## Unreleased

### Code Quality Improvements
* **Refactoring**: Major code refactoring for better maintainability
  - Fixed critical exception handling bug (Line 408) - now properly throws exceptions instead of silently failing
  - Fixed async method signature - `dismiss()` now correctly returns `Future<void>`
  - Improved triangle classes to use `pi` constant instead of hardcoded calculations
  - Added type parameters to GlobalKey declarations for better type safety
  - Added input validation with assert statements for `targetPadding`, `triangleRadius`, and `triangleSize`
  - Added comprehensive documentation comments to complex positioning logic
  - Improved code readability with inline comments

### Documentation
* **README**: Added comprehensive Korean (README.ko.md) and English (README.md) documentation
  - Detailed feature descriptions with examples
  - Complete API reference table
  - Platform support matrix
  - Comparison with Flutter's built-in Tooltip
  - Contributing guidelines
  - Multiple usage examples (basic, customized, controller, callbacks)
* **Assets**: Created assets directory structure for documentation images

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
