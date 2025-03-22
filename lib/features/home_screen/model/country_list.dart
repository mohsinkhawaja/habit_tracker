import 'dart:convert';
import 'package:http/http.dart' as http;

class CountryList {
  // Fetch countries from the REST Countries API
  static Future<List<String>> fetchCountries() async {
    final response =
        await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

    if (response.statusCode == 200) {
      // Decode the JSON response
      List<dynamic> countriesJson = json.decode(response.body);

      // Extract country names
      List<String> countryList = countriesJson
          .map((country) => country['name']['common'] as String)
          .toList();

      // Sort the country list alphabetically
      countryList.sort();

      return countryList;
    } else {
      throw Exception('Failed to load countries');
    }
  }
}
