import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TimeFilterSheet extends StatefulWidget {
  final Function onSave;
  final Function onSwitch;
  final bool trendlines;

  const TimeFilterSheet({
    super.key,
    required this.trendlines,
    required this.onSwitch,
    required this.onSave,
  });

  @override 
  State<TimeFilterSheet> createState() => _TimeFilterSheetState();
}

class _TimeFilterSheetState extends State<TimeFilterSheet> {
  bool _currentTrendlines = false;

  @override
  void initState() {
    super.initState();
    _currentTrendlines = widget.trendlines; // Initialize local state
  }

  @override
  Widget build(BuildContext context) {
    return ShadSheet(
      padding: const EdgeInsets.only(top: 120, left: 25, right: 25),
      closeIconPosition: ShadPosition(left: 20, top: 50),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 110),
      title: const Text('Edit charts'),
      description: const Text("Make changes to the way you want to view your data. Click save when you're done", textAlign: TextAlign.start,),
      actions: [
        ShadButton(
          child: Text('Save changes'),
          onPressed: () {
            widget.onSave(_currentTrendlines);
            Navigator.of(context).pop(); // Close the sheet
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadSwitch(
              value: _currentTrendlines,
              onChanged: (value) {
                setState(() {
                  _currentTrendlines = value; // Update local state
                });
                widget.onSwitch(value); // Notify parent of the change
              },
              label: const Text('Trendlines'),
            ),
          ]
        ),
      ),
    );
  }
}