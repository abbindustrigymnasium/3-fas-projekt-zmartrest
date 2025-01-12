import 'package:flutter/material.dart';

import 'package:zmartrest/widgets/select_user_search.dart';
import 'package:zmartrest/pocketbase.dart';
import 'package:zmartrest/screens/data_visualization_screen.dart';
import 'package:zmartrest/main_scaffold.dart';

class AnalyzeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserSelected;
  
  const AnalyzeScreen({
    super.key, 
    required this.onUserSelected,
  });

  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  // List to store users
  List<Map<String, dynamic>> users = [];

  Map<String, dynamic>? _selectedUser;
  bool _isLoading = true;
  bool _hide_select_user = false;

  @override
  void initState() {
    super.initState();
    // Fetch users when the page initializes
    _loadUsers();
  }

  // Method to fetch users
  Future<void> _loadUsers() async {
    try {
      final fetchedUsers = await fetchAllUsers(pb);
      setState(() {
        users = fetchedUsers;
        _isLoading = false;
      });
    } catch (e) {
      // Handle any errors (show a snackbar, etc.)
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Start by selecting a user", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_isLoading) const CircularProgressIndicator(),
          if (_isLoading == false && _hide_select_user == false) 
            SelectUserWithSearch(
              users: users,
              onUserSelected: (user) {
                setState(() {
                  _selectedUser = user;
                  _hide_select_user = true;
                });
                widget.onUserSelected(user); // Call the callback instead of navigating
              },
            ),
        ]
      )
    );
  }
}