import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:habit_tracker/features/home_screen/model/country_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  double _age = 25.0; // Ensure age is a double
  String _country = 'United States';
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _loadUserData();
  }

  Future<void> _loadCountries() async {
    try {
      List<String> fetchedCountries = await CountryList.fetchCountries();
      setState(() {
        _countries = fetchedCountries;
        _country = _countries.contains(_country) ? _country : _countries.first;
      });
    } catch (e) {
      debugPrint('Error fetching countries: $e');
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';

      // Fetch 'age' and ensure it's stored as a double
      dynamic ageValue = prefs.get('age'); // Get as dynamic
      if (ageValue is int) {
        _age = ageValue.toDouble(); // Convert int to double
      } else if (ageValue is double) {
        _age = ageValue;
      } else {
        _age = 25.0; // Default value
      }

      _country = prefs.getString('country') ?? 'United States';
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setDouble('age', _age); // Save as double
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
      appBar: AppBar(title: const Text('Personal Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 20),
              const Text('Age'),
              Slider(
                value: _age,
                min: 18,
                max: 100,
                onChanged: (value) => setState(() => _age = value),
              ),
              const SizedBox(height: 20),
              const Text('Country'),
              FutureBuilder<List<String>>(
                future: CountryList.fetchCountries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Failed to load countries');
                  } else {
                    List<String> countries = snapshot.data!;
                    return DropdownButton<String>(
                      value: _country ?? countries.first,
                      onChanged: (newValue) =>
                          setState(() => _country = newValue!),
                      items: countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
