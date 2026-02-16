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
class CitySearchService {
  // Кеш последних запросов — чтобы не грузить повторно
  static final Map<String, List<CitySearchResult>> _cache = {};
  static const int _maxCacheSize = 20;

  static Future<List<CitySearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    // Проверяем кеш
    final cacheKey = trimmed.toLowerCase();
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(trimmed)}'
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

        final displayName = item['display_name'] ?? '';
        final parts = displayName.split(', ');
        final name = parts.isNotEmpty ? parts.first : trimmed;
        final country = parts.length > 1 ? parts.last : '';

        results.add(CitySearchResult(
          name: name,
          country: country,
          displayName: displayName,
          latitude: lat,
          longitude: lon,
        ));
      }

      // Сохраняем в кеш (с ограничением размера)
      if (_cache.length >= _maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }
      _cache[cacheKey] = results;

      return results;
    } catch (e) {
      debugPrint('❌ Ошибка поиска: $e');
      return [];
    }
  }

  /// Очистка кеша
  static void clearCache() => _cache.clear();
}