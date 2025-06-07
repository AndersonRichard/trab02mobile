import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/country.dart';

class CountryTile extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;

  const CountryTile({required this.country, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: country.flagUrl,
        width: 50,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      title: Text(country.name.isNotEmpty ? country.name : 'Nome não disponível'),
      onTap: onTap,
    );
  }
}
  