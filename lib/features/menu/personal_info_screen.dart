import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  double _age = 25;
  String _country = 'United States';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _age = prefs.getDouble('age') ?? 25;
      _country = prefs.getString('country') ?? 'United States';
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setDouble('age', _age);
    await prefs.setString('country', _country);

    Fluttertoast.showToast(
      msg: "Profile updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Info')),
      body: Column(
        children: [
          TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name')),
          TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username')),
          Slider(
              value: _age,
              min: 18,
              max: 100,
              onChanged: (value) => setState(() => _age = value)),
          DropdownButton<String>(
            value: _country,
            onChanged: (newValue) => setState(() => _country = newValue!),
            items: ['United States', 'Canada', 'India']
                .map((country) =>
                    DropdownMenuItem(value: country, child: Text(country)))
                .toList(),
          ),
          ElevatedButton(onPressed: _saveUserData, child: Text('Save Changes')),
        ],
      ),
    );
  }
}
