import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _habitController = TextEditingController();
  Color selectedColor = Colors.amber; // Default color
  Map<String, String> selectedHabitsMap = {};
  Map<String, String> completedHabitsMap = {};
  final Map<String, Color> _habitColors = {
    'Amber': Colors.amber,
    'Red Accent': Colors.redAccent,
    'Light Blue': Colors.lightBlue,
    'Light Green': Colors.lightGreen,
    'Purple Accent': Colors.purpleAccent,
    'Orange': Colors.orange,
    'Teal': Colors.teal,
    'Deep Purple': Colors.deepPurple,
  };
  String selectedColorName = 'Amber'; // Default color name

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedHabitsJson = prefs.getString('selectedHabits');
    final completedHabitsJson = prefs.getString('completedHabits');

    setState(() {
      if (selectedHabitsJson != null) {
        selectedHabitsMap =
            Map<String, String>.from(jsonDecode(selectedHabitsJson));
      }
      if (completedHabitsJson != null) {
        completedHabitsMap =
            Map<String, String>.from(jsonDecode(completedHabitsJson));
      }
    });
  }

  // Future<void> _saveHabit() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final habit = _habitController.text.trim();

  //   if (habit.isNotEmpty) {
  //     // Load existing habits
  //     final habitsJson = prefs.getString('selectedHabitsMap') ?? '{}';
  //     final habitsMap = Map<String, String>.from(jsonDecode(habitsJson));

  //     // Add new habit with the selected color
  //     habitsMap[habit] = selectedColor.value.toRadixString(16);

  //     // Save updated habits
  //     await prefs.setString('selectedHabitsMap', jsonEncode(habitsMap));

  //     // Navigate back to HabitTrackerScreen
  //     Navigator.pop(context, true); // Pass `true` to indicate success
  //   } else {
  //     // Show error message if the habit field is empty
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a habit.'),
  //       ),
  //     );
  //   }
  // }
  Future<void> _saveHabit() async {
    final prefs = await SharedPreferences.getInstance();
    final habit = _habitController.text.trim();

    if (habit.isNotEmpty) {
      // Load existing habits
      final habitsJson = prefs.getString('selectedHabits') ?? '{}';
      final habitsMap = Map<String, String>.from(jsonDecode(habitsJson));

      // Add new habit with the selected color
      habitsMap[habit] = selectedColor.value.toRadixString(16);

      // Save updated habits
      await prefs.setString('selectedHabits', jsonEncode(habitsMap));

      // Navigate back to HabitTrackerScreen
      Navigator.pop(context, true); // Pass `true` to indicate success
    } else {
      // Show error message if the habit field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a habit.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Combine both maps for display, ensuring no duplicates
    Map<String, String> allHabitsMap = {
      ...selectedHabitsMap,
      ...completedHabitsMap
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Configure Habits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back without saving
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _habitController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Color:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                value: selectedColorName,
                isExpanded: true,
                underline: const SizedBox(),
                items: _habitColors.keys.map((String colorName) {
                  return DropdownMenuItem<String>(
                    value: colorName,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _habitColors[colorName],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        colorName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedColorName = newValue!;
                    selectedColor = _habitColors[selectedColorName]!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_habitController.text.isNotEmpty) {
                  _saveHabit(); // Save the habit
                } else {
                  // Show error message if the habit field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a habit.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Add Habit',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: allHabitsMap.entries.map((entry) {
                  final habitName = entry.key;
                  final habitColor = _getColorFromHex(entry.value);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: habitColor,
                    ),
                    title: Text(habitName),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          // Remove habit from both maps if it exists
                          selectedHabitsMap.remove(habitName);
                          completedHabitsMap.remove(habitName);
                        });
                        _saveHabit(); // Save habits to local storage
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not included.
    }
    return Color(int.parse('0x$hexColor'));
  }
}
