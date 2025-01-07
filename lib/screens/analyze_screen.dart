import 'package:flutter/material.dart';
import 'package:zmartrest/widgets/select_user_search.dart';
import 'package:zmartrest/pocketbase.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  _AnalyzeScreenState createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {

  // List to store users
  List<Map<String, dynamic>> users = [];

  Map<String, dynamic>? _selectedUser;
  bool _isLoading = true;

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("Start by selecting a user", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SelectUserWithSearch(
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
                    ],
                  ]
                )
              )
            ],
          ),
        ) 
      ),
    );
  }
}