import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Результат поиска города
class CitySearchResult {
  final String name;
  final String country;
  final String displayName;
  final double latitude;
  final double longitude;

  const CitySearchResult({
    required this.name,
    required this.country,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  String get fullName => '$name, $country';
}

/// Сервис поиска городов через Nominatim (OpenStreetMap)
/// Бесплатный, без API-ключа
class CitySearchService {
  static Future<List<CitySearchResult>> search(String query) async {
    if (query.trim().length < 2) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(query)}'
            '&format=json'
            '&limit=10'
            '&accept-language=ru'
            '&featuretype=city,town,village',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'PrayerTimeApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return [];

      final List data = jsonDecode(response.body);
      final results = <CitySearchResult>[];

      for (final item in data) {
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lon = double.tryParse(item['lon']?.toString() ?? '');
        if (lat == null || lon == null) continue;

        // Разбираем display_name чтобы получить город и страну
        final displayName = item['display_name'] ?? '';
        final parts = displayName.split(', ');

        final name = parts.isNotEmpty ? parts.first : query;
        final country = parts.length > 1 ? parts.last : '';

        results.add(CitySearchResult(
          name: name,
          country: country,
          displayName: displayName,
          latitude: lat,
          longitude: lon,
        ));
      }

      return results;
    } catch (e) {
      debugPrint('❌ Ошибка поиска: $e');
      return [];
    }
  }
}