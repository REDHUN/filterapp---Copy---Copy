import 'package:dio/dio.dart';

import '../models/filter_option.dart';
import '../models/filter_section.dart';
import '../models/venue_result.dart';

class FilterService {
  static const String baseUrl = 'https://atom1.blueferns.com/test';
  final Dio _dio;

  FilterService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<FilterSection>> getFilters() async {
    try {
      final response = await _dio.get('$baseUrl/filter.json');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return _parseFilterSections(data);
      } else {
        throw Exception('Failed to load filters');
      }
    } catch (e) {
      throw Exception('Error fetching filters: $e');
    }
  }

  List<FilterSection> _parseFilterSections(List<dynamic> data) {
    return data.map((section) {
      List<FilterOption> options = [];
      final String sectionSlug = section['slug'];

      if (sectionSlug == 'location') {
        final locations = section['taxonomies'][0]['locations'] as List;
        options = locations
            .map((location) => FilterOption(
                  id: location['slug'],
                  title: location['name'],
                ))
            .toList();
      } else {
        options = (section['taxonomies'] as List?)
                ?.map((taxonomy) => FilterOption(
                      id: taxonomy['slug'],
                      title: taxonomy['name'],
                    ))
                .toList() ??
            [];
      }

      return FilterSection(
        title: section['name'],
        slug: sectionSlug,
        options: options,
      );
    }).toList();
  }

  Future<List<VenueResult>> getFilteredResults(
      Map<String, dynamic> filters) async {
    try {
      final response = await _dio.get('$baseUrl/filter.json');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return _parseFilteredResults(data, filters);
      } else {
        throw Exception('Failed to load results');
      }
    } catch (e) {
      throw Exception('Error fetching results: $e');
    }
  }

  List<VenueResult> _parseFilteredResults(
      List<dynamic> data, Map<String, dynamic> filters) {
    final selectedFilters = filters.map((key, value) =>
        MapEntry(key, value is List ? value.cast<String>() : []));

    final List<VenueResult> results = [];
    for (var section in data) {
      final sectionSlug = section['slug'];
      if (selectedFilters.containsKey(sectionSlug) &&
          selectedFilters[sectionSlug]!.isNotEmpty) {
        final selectedValues = selectedFilters[sectionSlug]!;
        final taxonomies = section['taxonomies'] as List;

        for (var taxonomy in taxonomies) {
          if (selectedValues.contains(taxonomy['slug'])) {
            results.add(VenueResult(
              id: taxonomy['id'].toString(),
              name: taxonomy['name'],
              description: taxonomy['name'],
              image: 'https://example.com/placeholder.jpg',
              cuisines: [taxonomy['name']],
              dietaryOptions: [],
              location: section['name'],
              rating: 4.5,
            ));
          }
        }
      }
    }

    return results;
  }
}
