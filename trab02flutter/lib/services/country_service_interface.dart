import '../models/country.dart';

abstract class ICountryService {
  Future<List<Country>> fetchAllCountries();
  Future<Country?> fetchCountryByName(String name);
}
