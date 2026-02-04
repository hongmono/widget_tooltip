import 'package:flutter/material.dart';

/// A controller for programmatically showing and hiding a [WidgetTooltip].
///
/// This controller can be passed to [WidgetTooltip.controller] to enable
/// manual control over the tooltip's visibility.
///
/// To ensure only one tooltip is visible at a time, use [TooltipGroup]:
/// ```dart
/// final group = TooltipGroup();
/// final controller1 = TooltipController(group: group);
/// final controller2 = TooltipController(group: group);
/// ```
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
  /// Creates a tooltip controller.
  ///
  /// If [group] is provided, showing this tooltip will automatically
  /// dismiss any other tooltip in the same group.
  TooltipController({TooltipGroup? group}) : _group = group {
    _group?._register(this);
  }

  final TooltipGroup? _group;
  bool _isShow = false;

  /// Whether the tooltip is currently visible.
  bool get isShow => _isShow;

  /// Shows the tooltip.
  ///
  /// If this controller belongs to a [TooltipGroup], all other tooltips
  /// in the group will be dismissed first.
  ///
  /// Notifies listeners when the visibility changes.
  void show() {
    _group?._onShow(this);
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

  @override
  void dispose() {
    _group?._unregister(this);
    super.dispose();
  }
}

/// A group that ensures only one tooltip is visible at a time.
///
/// When a tooltip in the group is shown, all other tooltips in the
/// same group are automatically dismissed.
///
/// Example:
/// ```dart
/// final group = TooltipGroup();
///
/// // These controllers are linked — only one tooltip shows at a time.
/// final controller1 = TooltipController(group: group);
/// final controller2 = TooltipController(group: group);
/// final controller3 = TooltipController(group: group);
///
/// // Showing controller2 will automatically dismiss controller1 (or 3).
/// controller2.show();
/// ```
class TooltipGroup {
  final Set<TooltipController> _controllers = {};

  void _register(TooltipController controller) {
    _controllers.add(controller);
  }

  void _unregister(TooltipController controller) {
    _controllers.remove(controller);
  }

  void _onShow(TooltipController showing) {
    for (final controller in _controllers) {
      if (controller != showing && controller.isShow) {
        controller.dismiss();
      }
    }
  }

  /// Dismisses all tooltips in this group.
  void dismissAll() {
    for (final controller in _controllers) {
      if (controller.isShow) {
        controller.dismiss();
      }
    }
  }
}
