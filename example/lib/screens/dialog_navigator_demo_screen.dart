import 'package:flutter/material.dart';
import '../custom_pages.dart';

/// Demonstrates custom dialog usage with FFR.
///
/// Shows both default and custom styled dialogs.
class DialogNavigatorDemoScreen extends StatelessWidget {
  const DialogNavigatorDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dialog Navigator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Default Dialogs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.info),
            label: const Text('Show Info Dialog'),
            onPressed: () => _showDefaultInfoDialog(context),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.warning),
            label: const Text('Show Confirm Dialog'),
            onPressed: () => _showDefaultConfirmDialog(context),
          ),
          const SizedBox(height: 32),
          const Text(
            'Custom Dialogs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.palette),
            label: const Text('Show Custom Info Dialog'),
            onPressed: () => _showCustomInfoDialog(context),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.help),
            label: const Text('Show Custom Confirm Dialog'),
            onPressed: () => _showCustomConfirmDialog(context),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Default Dialogs
  // ============================================================================

  Future<void> _showDefaultInfoDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Information'),
          content: const Text(
            'This is a default styled dialog with information. '
            'You can use dialogs for confirmations, alerts, or forms.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDefaultConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content: const Text('Are you sure you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (context.mounted && result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action confirmed!')),
      );
    }
  }

  // ============================================================================
  // Custom Dialogs
  // ============================================================================

  Future<void> _showCustomInfoDialog(BuildContext context) async {
    final design = CustomDesignSystem.darkTheme;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: design.dialogShape,
          backgroundColor: design.dialogBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Color(0xFF89B4FA), size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Information',
                      style: design.dialogTitleStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'This is a custom styled dialog using your design system. '
                  'You can fully customize colors, shapes, and typography.',
                  style: design.dialogContentStyle,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF89B4FA),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCustomConfirmDialog(BuildContext context) async {
    final design = CustomDesignSystem.darkTheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: design.dialogShape,
          backgroundColor: design.dialogBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Color(0xFFF9E2AF), size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Confirm Action',
                      style: design.dialogTitleStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'This action will modify your data. Do you want to continue?',
                  style: design.dialogContentStyle,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFA6ADC8),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA6E3A1),
                        foregroundColor: const Color(0xFF1E1E2E),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (context.mounted && result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action confirmed with custom dialog!'),
          backgroundColor: Color(0xFFA6E3A1),
        ),
      );
    }
  }
}
