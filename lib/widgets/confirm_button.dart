import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ConfirmButton extends StatelessWidget {
  final String buttonText;
  final String dialogTitle;
  final String dialogDescription;
  final VoidCallback onConfirm; // Accept a function that will be executed on confirm

  // Constructor accepts the text for the button, title, description, and the onConfirm function
  const ConfirmButton({
    super.key,
    required this.buttonText,
    required this.dialogTitle,
    required this.dialogDescription,
    required this.onConfirm, // Pass the onConfirm function as a parameter
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton.destructive(
      child: Text(buttonText), // Use the button text passed to the widget
      onPressed: () {
        showShadDialog(
          context: context,
          builder: (context) => ShadDialog.alert(
            title: Text(dialogTitle), // Use the dialog title passed to the widget
            description: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(dialogDescription), // Use the dialog description passed to the widget
            ),
            actions: [
              ShadButton.outline(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ShadButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onConfirm(); 
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
