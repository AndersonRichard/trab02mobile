import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_service.dart';
import '../components/country_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountryListPage extends StatefulWidget {
  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  final int pageSize = 10;
  int currentIndex = 0;
  List<Country> countries = [];
  List<Country> allCountries = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    allCountries = await CountryService.fetchAllCountries();
    loadMoreCountries();
  }

  void loadMoreCountries() {
    if (isLoading) return;

    setState(() => isLoading = true);

    Future.delayed(Duration(milliseconds: 500), () {
      int nextIndex = currentIndex + pageSize;
      if (nextIndex > allCountries.length) nextIndex = allCountries.length;

      countries.addAll(allCountries.getRange(currentIndex, nextIndex));
      currentIndex = nextIndex;

      setState(() => isLoading = false);
    });
  }

  void showCountryDetails(Country country) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(country.name,
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                CachedNetworkImage(imageUrl: country.flagUrl, height: 80),
                SizedBox(height: 10),
                Text("Capital: ${country.capital}"),
                Text("Região: ${country.region}"),
                Text("População: ${country.population}"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Países - Lazy Load')),
      body: countries.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: countries.length + 1,
              itemBuilder: (context, index) {
                if (index == countries.length) {
                  if (countries.length < allCountries.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      loadMoreCountries();
                    });
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }

                final country = countries[index];

                return CountryTile(
                  country: country,
                  onTap: () => showCountryDetails(country),
                );
              },
            ),
    );
  }
}
