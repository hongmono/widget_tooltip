import 'package:flutter/material.dart';

/// A controller for programmatically showing and hiding a [WidgetTooltip].
///
/// This controller can be passed to [WidgetTooltip.controller] to enable
/// manual control over the tooltip's visibility.
///
/// Example:
/// ```dart
/// final controller = TooltipController();
///
/// WidgetTooltip(
///   controller: controller,
///   message: Text('Hello'),
///   child: Icon(Icons.info),
/// )
///
/// // Show tooltip programmatically
/// controller.show();
///
/// // Hide tooltip programmatically
/// controller.dismiss();
/// ```
class TooltipController extends ChangeNotifier {
  bool _isShow = false;

  /// Whether the tooltip is currently visible.
  bool get isShow => _isShow;

  /// Shows the tooltip.
  ///
  /// Notifies listeners when the visibility changes.
  void show() {
    _isShow = true;
    notifyListeners();
  }

  /// Dismisses the tooltip.
  ///
  /// The optional [event] parameter is ignored but allows this method
  /// to be used directly as a callback for tap events.
  ///
  /// Notifies listeners when the visibility changes.
  void dismiss([PointerDownEvent? event]) {
    _isShow = false;
    notifyListeners();
  }

  /// Toggles the tooltip visibility.
  ///
  /// Shows the tooltip if it's hidden, hides it if it's visible.
  void toggle() => _isShow ? dismiss() : show();
}
