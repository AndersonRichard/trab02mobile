class Country {
  final String name;
  final String flagUrl;
  final String capital;
  final String region;
  final int population;

  Country({
    required this.name,
    required this.flagUrl,
    required this.capital,
    required this.region,
    required this.population,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'] ?? 'N/A',
      flagUrl: json['flags']['png'] ?? '',
      capital: (json['capital'] != null && json['capital'].isNotEmpty)
          ? json['capital'][0]
          : 'N/A',
      region: json['region'] ?? 'N/A',
      population: json['population'] ?? 0,
    );
  }
}
