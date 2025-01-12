import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key, 
    required this.currentIndex, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 34, 34, 34),
        borderRadius: BorderRadius.circular(64),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12), // Adjust as needed
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //_buildNavItem(0, Icons.person, 'Account'),
            _buildNavItem(0, Icons.settings, 'Settings', context),
            _buildNavItem(1, Icons.analytics, 'Analyze', context),
            _buildNavItem(2, Icons.bluetooth, 'Measure', context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      /*
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(64),
      ),*/
      decoration: BoxDecoration(
        color: currentIndex == index
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.black26 // in dark mode
                : Colors.white24) // in light mode
            : Colors.transparent,
        borderRadius: BorderRadius.circular(64),
      ),
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: currentIndex == index ? Colors.white : Colors.grey,
              size: 24,
            ),
            if (currentIndex == index) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: currentIndex == index ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}