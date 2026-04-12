import 'package:flutter/material.dart';

// ============================================================================
// Custom Dialog Page
// ============================================================================

/// Custom dialog page that applies a custom theme to dialogs.
class CustomDialogPage<T> extends Page<T> {
  final Widget child;
  final Widget Function(BuildContext, Widget)? dialogBuilder;

  const CustomDialogPage({
    required this.child,
    this.dialogBuilder,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: (context) {
        final dialog = child;
        if (dialogBuilder != null) {
          return dialogBuilder!(context, dialog);
        }
        return dialog;
      },
    );
  }
}

// ============================================================================
// Custom BottomSheet Page
// ============================================================================

/// Custom bottom sheet page that allows full customization.
class CustomBottomSheetPage<T> extends Page<T> {
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final Color? barrierColor;
  final bool isScrollControlled;
  final bool useSafeArea;
  final BoxConstraints? constraints;

  const CustomBottomSheetPage({
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.barrierColor,
    this.isScrollControlled = true,
    this.useSafeArea = true,
    this.constraints,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      builder: (context) => child,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      constraints: constraints,
    );
  }
}

// ============================================================================
// Customization Theme Data
// ============================================================================

/// Holds custom styling for the design system.
class CustomDesignSystem {
  // Dialog styles
  final ShapeBorder dialogShape;
  final Color dialogBackgroundColor;
  final TextStyle dialogTitleStyle;
  final TextStyle dialogContentStyle;

  // BottomSheet styles
  final ShapeBorder bottomSheetShape;
  final Color bottomSheetBackgroundColor;
  final Color bottomSheetBarrierColor;

  // Alert styles
  final ShapeBorder alertShape;
  final Color alertBackgroundColor;
  final TextStyle alertTitleStyle;

  const CustomDesignSystem({
    this.dialogShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.dialogBackgroundColor = const Color(0xFF1E1E2E),
    this.dialogTitleStyle = const TextStyle(
      color: Color(0xFFCDD6F4),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    this.dialogContentStyle = const TextStyle(
      color: Color(0xFFA6ADC8),
      fontSize: 16,
    ),
    this.bottomSheetShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    this.bottomSheetBackgroundColor = const Color(0xFF1E1E2E),
    this.bottomSheetBarrierColor = const Color(0x99000000),
    this.alertShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    this.alertBackgroundColor = const Color(0xFF1E1E2E),
    this.alertTitleStyle = const TextStyle(
      color: Color(0xFFF38BA8),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  });

  static const darkTheme = CustomDesignSystem();

  static const lightTheme = CustomDesignSystem(
    dialogBackgroundColor: Colors.white,
    dialogTitleStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
    dialogContentStyle: TextStyle(color: Colors.black54, fontSize: 16),
    bottomSheetBackgroundColor: Colors.white,
    alertBackgroundColor: Colors.white,
    alertTitleStyle: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
  );
}
