import 'package:flutter/material.dart';
import 'package:zmartrest/widgets/select_user_with_search';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  // Example user list - replace with your actual user data source
  final List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
    },
    // Add more users as needed
  ];

  Map<String, dynamic>? _selectedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserSelectWithSearch(
              users: users,
              onUserSelected: (user) {
                setState(() {
                  _selectedUser = user;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedUser != null) ...[
              Text('Selected User: ${_selectedUser!['name']}'),
              Text('Email: ${_selectedUser!['email']}'),
              // Add more user details or analysis widgets here
            ],
          ],
        ),
      ),
    );
  }
}