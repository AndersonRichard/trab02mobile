import 'package:flutter/material.dart';
import 'screens/country_list_page.dart';
import 'services/country_service.dart';

void main() {
  runApp(MaterialApp(
    home: CountryListPage(countryService: CountryService()),
    debugShowCheckedModeBanner: false,
  ));
}
