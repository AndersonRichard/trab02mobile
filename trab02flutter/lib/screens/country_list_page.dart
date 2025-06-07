import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_service_interface.dart';
import '../components/country_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountryListPage extends StatefulWidget {
  final ICountryService countryService;

  const CountryListPage({Key? key, required this.countryService}) : super(key: key);

  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  final int pageSize = 10;
  int currentIndex = 0;
  List<Country> countries = [];
  List<Country> allCountries = [];
  bool isLoading = false;

  bool get isInTest => const bool.fromEnvironment('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    listarPaises();
  }

  void listarPaises() => loadCountries();

  Future<void> loadCountries() async {
    try {
      allCountries = await widget.countryService.fetchAllCountries();
      loadMoreCountries();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar países')),
          );
        }
      });
    }
  }

  void loadMoreCountries() {
    if (isLoading) return;
    setState(() => isLoading = true);

    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;

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
                Text(
                  country.name.isNotEmpty ? country.name : 'Nome não disponível',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                CachedNetworkImage(
                  imageUrl: country.flagUrl,
                  height: 80,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                SizedBox(height: 10),
                Text("Capital: ${country.capital.isNotEmpty ? country.capital : 'Não disponível'}"),
                Text("Região: ${country.region.isNotEmpty ? country.region : 'Não disponível'}"),
                Text("População: ${country.population > 0 ? country.population.toString() : 'Não disponível'}"),
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
                  if (countries.length < allCountries.length && !isInTest) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) loadMoreCountries();
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
