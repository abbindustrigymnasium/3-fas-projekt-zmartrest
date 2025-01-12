import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/widgets/shad_select_theme_widget.dart';
import 'package:zmartrest/screens/login_screen.dart';
import 'package:zmartrest/widgets/confirm_button.dart';
import 'package:zmartrest/pocketbase.dart';

class SettingsScreen extends StatelessWidget {
  final Function(String) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  Future<Map<String, dynamic>?> _getUserInfo() async {
    return await getUserInfo();  // Fetch user info from PocketBase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _getUserInfo(), // Fetch user info
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator()); // Loading state
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final userInfo = snapshot.data;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 1),
                    child: const Text(
                      "Account",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (userInfo != null) ...[
                    // Display user info
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username: ${userInfo['username'] ?? 'N/A'}'),
                          Text('Email: ${userInfo['email'] ?? 'N/A'}'),
                          Text('Account created: ${userInfo['created'] ?? 'N/A'}'),
                          Text('Last updated: ${userInfo['updated'] ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Show a message if user info is not available
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text('User info not available. Please log in again.'),
                    ),
                  ],
                  ConfirmButton(
                    buttonText: "Logout",
                    dialogTitle: "Confirm Logout",
                    dialogDescription: "Are you sure you want to logout?",
                    onConfirm: () {
                      logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(onThemeChanged: onThemeChanged),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 1),
                    child: const Text(
                      "Language",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ShadSelect(
                    initialValue: 'English',
                    maxHeight: 200,
                    minWidth: 300,
                    options: ['English', 'Swedish'].map(
                      (option) => ShadOption(
                        value: option,
                        child: Text(option),
                      ),
                    ),
                    selectedOptionBuilder: (context, value) {
                      return Text(value);
                    },
                    onChanged: (value) {
                      // Your code to handle the selected value
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 1),
                    child: const Text(
                      "Theme",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ShadSelectThemeWidget(
                    initialTheme: 'light', // Set a default value
                    onThemeChanged: onThemeChanged,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(bottom: 10, left: 1), child: const Text("Account", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              // display user info
              // ...
              ConfirmButton(buttonText: "Logout", dialogTitle: "Confirm Logout", dialogDescription: "Are you sure you want to logout?", onConfirm: () {
                logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(onThemeChanged: onThemeChanged,),
                  ),
                );
              }),
              const SizedBox(height: 80),
              Padding(padding: const EdgeInsets.only(bottom: 10, left: 1), child: const Text("Language", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              ShadSelect(
                initialValue: 'English',
                maxHeight: 200,
                minWidth: 300,
                options: ['English', 'Swedish'].map(
                  (option) => ShadOption(
                    value: option,
                    child: Text(option),
                  ),
                ),
                selectedOptionBuilder: (context, value) {
                  return Text(value);
                },
                onChanged: (value) {
                  // Your code to handle the selected value
                },
              ),
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.only(bottom: 10, left: 1), child: const Text("Theme", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              ShadSelectThemeWidget(
                initialTheme: 'light', // Set a default value
                onThemeChanged: onThemeChanged,
              ),
            ],
          )
        )
      ),
    );
  }
  */
}