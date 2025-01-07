import 'package:flutter/material.dart';
import 'package:zmartrest/screens/account_screen.dart';
import 'package:zmartrest/screens/measure_screen.dart';
import 'package:zmartrest/screens/analyze_screen.dart';
import 'package:zmartrest/widgets/custom_bottom_nav.dart';



class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const AccountScreen(),
    const AnalyzeScreen(),
    const DeviceScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  /*

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Inspect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Measure',
          ),
        ],
      ),
    );
  }
  */
}