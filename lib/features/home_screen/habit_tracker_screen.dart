import 'package:flutter/material.dart';
import 'package:habit_tracker/features/authentication/login_screen.dart';
import 'package:habit_tracker/features/detailscreen/detail_screen.dart';
import 'add_habit_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitTrackerScreen extends StatefulWidget {
  final String username;

  const HabitTrackerScreen({super.key, required this.username});

  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  Map<String, String> selectedHabitsMap = {};
  Map<String, String> completedHabitsMap = {};

  @override
  void initState() {
    super.initState();
    _loadHabits(); // Load habits when the screen is created
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString('selectedHabits');
    if (habitsJson != null) {
      setState(() {
        selectedHabitsMap = Map<String, String>.from(jsonDecode(habitsJson));
      });
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedHabits', jsonEncode(selectedHabitsMap));
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all user data from SharedPreferences
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not included.
    }
    return Color(int.parse('0x$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Center(
          child: Text(
            widget.username,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      // Add Drawer here
      drawer: Drawer(
        backgroundColor: Color(0xffFDF1FE), // Light purple background
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700, // Blue header
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.menu,
                color: Colors.black,
              ),
              title: const Text(
                'Habit',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddHabitScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.black,
              ),
              title: const Text(
                'Personal Info',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to Personal Info Screen (you can add this later)
              },
            ),
            ListTile(
              leading: Icon(
                Icons.report,
                color: Colors.black,
              ),
              title: const Text(
                'Report',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to Report Screen (you can add this later)
              },
            ),
            ListTile(
              leading: Icon(
                Icons.notifications_rounded,
                color: Colors.black,
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to Notifications Screen (you can add this later)
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout_outlined,
                color: Colors.black,
              ),
              title: const Text(
                'Sign out',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Sign-out logic
                _clearUserData().then((_) {
                  // Navigate to LoginScreen and remove all previous screens
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'To Do 📝',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          selectedHabitsMap.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text(
                      'Use the + button to create some habits!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: selectedHabitsMap.length,
                    itemBuilder: (context, index) {
                      String habit = selectedHabitsMap.keys.elementAt(index);
                      Color habitColor =
                          _getColorFromHex(selectedHabitsMap[habit]!);
                      return Dismissible(
                        key: Key(habit),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            String color = selectedHabitsMap.remove(habit)!;
                            completedHabitsMap[habit] = color;
                            _saveHabits();
                          });
                        },
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Swipe to Complete',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.check, color: Colors.white),
                            ],
                          ),
                        ),
                        child: _buildHabitCard(habit, habitColor),
                      );
                    },
                  ),
                ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Done ✅🎉',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          completedHabitsMap.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Swipe right on an activity to mark as done.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: completedHabitsMap.length,
                    itemBuilder: (context, index) {
                      String habit = completedHabitsMap.keys.elementAt(index);
                      Color habitColor =
                          _getColorFromHex(completedHabitsMap[habit]!);
                      return Dismissible(
                        key: Key(habit),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          setState(() {
                            String color = completedHabitsMap.remove(habit)!;
                            selectedHabitsMap[habit] = color;
                            _saveHabits();
                          });
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            children: [
                              Icon(Icons.undo, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Swipe to Undo',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        child: _buildHabitCard(habit, habitColor,
                            isCompleted: true),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddHabitScreen(),
            ),
          ).then((_) {
            // Reload habits when returning from AddHabitScreen
            _loadHabits();
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
        tooltip: 'Add Habits',
      ),
    );
  }

  Widget _buildHabitCard(String title, Color color,
      {bool isCompleted = false}) {
    return GestureDetector(
      onTap: () {
        // Navigate to DetailScreen with habit data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              item: {
                'title': title,
                'description': 'This is a detailed description of the habit.',
              },
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: color,
        child: Container(
          height: 60, // Adjust the height for thicker cards.
          child: ListTile(
            title: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                : null,
          ),
        ),
      ),
    );
  }
}
