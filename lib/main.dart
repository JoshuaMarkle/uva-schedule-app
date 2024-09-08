import 'package:flutter/material.dart';
import 'food.dart';
import 'library.dart';
import 'gym.dart';
import 'misc.dart';

void main() {
  runApp(UvaTimes());
}

class UvaTimes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UVA Services',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Main page with Bottom Navigation Bar
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages for bottom navigation
  static final List<Widget> _pages = <Widget>[
    const FoodPage(), // Page for Food
    LibraryPage(), // Page for Library
    GymPage(), // Page for Gym
    MiscPage(), // Page for Misc
  ];

  // Method to handle tapping the bottom navigation items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Gym',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Misc',
          ),
        ],
        currentIndex: _selectedIndex, // The current selected index
        selectedItemColor: Colors.blue, // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        onTap: _onItemTapped, // Method to update index on tap
      ),
    );
  }
}
