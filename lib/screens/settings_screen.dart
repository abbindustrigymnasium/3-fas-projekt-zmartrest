import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:zmartrest/widgets/select_theme.dart';
import 'package:zmartrest/screens/login_screen.dart';
import 'package:zmartrest/widgets/confirm_button.dart';
import 'package:zmartrest/pocketbase.dart';
import 'package:zmartrest/widgets/zmartrest_logo.dart';
import 'package:zmartrest/app_constants.dart';
import 'package:zmartrest/widgets/divider.dart';

//import 'package:zmartrest/device_handler.dart';
import 'package:zmartrest/simulated_device_handler.dart';
import 'package:zmartrest/logic.dart';

class SettingsScreen extends StatelessWidget {
  final Function(String) onThemeChanged;
  final String currentTheme;
  final HealthMonitorSystem healthMonitorSystem;
  final DeviceHandler deviceHandler;
  final String userId;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
    required this.healthMonitorSystem,
    required this.deviceHandler,
    required this.userId,
  });

  Future<Map<String, dynamic>?> _getUserInfo() async {
    return await getUserInfo();  // Fetch user info from PocketBase
  }

  /*
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text("Settings", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  if (userInfo != null) ...[
                    // Display user info
                    ShadCard(
                      title: Padding(padding: EdgeInsets.only(bottom: 10, left: 5, right: 5), child: Text("Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      description: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Username: ${userInfo['username'] ?? 'N/A'}'),
                            Text('Email: ${userInfo['email'] ?? 'N/A'}'),
                            Text('Account created: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(userInfo['created']))}'),
                            Text('Last updated: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(userInfo['updated']))}'),
                          ],
                        ),
                      ),
                      width: MediaQuery.of(context).size.width - 60,
                      footer: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ConfirmButton(
                              buttonText: "Logout",
                              dialogTitle: "Confirm Logout",
                              dialogDescription: "Are you sure you want to logout?",
                              onConfirm: () {
                                logout();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(onThemeChanged: onThemeChanged, currentTheme: currentTheme, healthMonitorSystem: healthMonitorSystem, deviceHandler: deviceHandler),
                                  ),
                                );
                              },
                            ),
                            ShadButton.outline(
                              child: const Text('Change password'),
                              onPressed: () {
                                // todo
                              },
                            )
                          ],
                        ),
                      ) 
                    )
                  ] else ...[
                    // Show a message if user info is not available
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text('User info not available. Please log in again.', style: TextStyle(fontSize: 14, color: Colors.red)),
                    ),
                  ],
                  const SizedBox(height: 40),
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
                    minWidth: MediaQuery.of(context).size.width - 60,
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
                  SelectTheme(
                    onThemeChanged: onThemeChanged,
                    initialValue: currentTheme,
                  ),
                  const SizedBox(height: 100),
                  Container(
                    width: MediaQuery.of(context).size.width - 60,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Opacity(opacity: 0.5, child: ZmartrestLogo(currentTheme: currentTheme,)),
                        const SizedBox(height: 10),
                        Text("zmartrest analysis tool   v. $appVersion", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ]
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          //alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text("Settings", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // User Info Section
              FutureBuilder<Map<String, dynamic>?>(
                future: _getUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Loading state
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final userInfo = snapshot.data;
                  if (userInfo == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        'User info not available. Please log in again.',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    );
                  }

                  return ShadCard(
                    title: Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 5, right: 5),
                      child: Text("Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    description: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username: ${userInfo['username'] ?? 'N/A'}'),
                          Text('Email: ${userInfo['email'] ?? 'N/A'}'),
                          Text('Account created: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(userInfo['created']))}'),
                          Text('Last updated: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(userInfo['updated']))}'),
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width - 60,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConfirmButton(
                            buttonText: 'Logout',
                            dialogTitle: 'Confirm Logout',
                            dialogDescription: 'Are you sure you want to logout?',
                            onConfirm: () {
                              logout();
                              /*
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                    onThemeChanged: onThemeChanged,
                                    currentTheme: currentTheme,
                                    healthMonitorSystem: healthMonitorSystem,
                                    deviceHandler: deviceHandler,
                                    userId: userId,
                                  ),
                                ),
                              );
                              */
                            },
                            buttonVariant: ShadButtonVariant.outline,
                          ),
                          ConfirmButton(
                            buttonText: 'Delete all data',
                            dialogTitle: 'Confirm deletion of all data',
                            dialogDescription: 'Are you absolutely sure you want to delete all data? This action cannot be undone.',
                            onConfirm: () {
                              deleteDataExceptFirst(pb, userId, 0);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Language Selection Section
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
                minWidth: MediaQuery.of(context).size.width - 60,
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
                  // TODO: Handle language change
                },
              ),

              const SizedBox(height: 20),

              // Theme Selection Section
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 1),
                child: const Text(
                  "Theme",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SelectTheme(
                onThemeChanged: onThemeChanged,
                initialValue: currentTheme,
              ),

              const SizedBox(height: 60),

              VisualDivider(currentTheme: currentTheme),

              // Footer Section
              Container(
                width: MediaQuery.of(context).size.width - 60,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: ZmartrestLogo(currentTheme: currentTheme),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "zmartrest analysis tool   v. $appVersion",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
