import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'country_service_interface.dart';

class CountryService implements ICountryService {
  @override
  Future<List<Country>> fetchAllCountries() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags,capital,region,population'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      data.sort((a, b) => a['name']['common']
          .toString()
          .compareTo(b['name']['common'].toString()));
      return data.map((json) => Country.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  @override
  Future<Country?> fetchCountryByName(String name) async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/name/$name'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return Country.fromJson(data.first);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load country');
    }
  }
}
