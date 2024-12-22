import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/filter_option.dart';
import '../models/filter_section.dart';
import '../models/venue_result.dart';

class FilterService {
  static const String baseUrl = 'https://atom1.blueferns.com/test';

  Future<List<FilterSection>> fetchFilters() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filter.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];

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
      } else {
        throw Exception('Failed to load filters');
      }
    } catch (e) {
      throw Exception('Error fetching filters: $e');
    }
  }

  Future<List<VenueResult>> fetchFilteredResults(
      Map<String, dynamic> filters) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filter.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];

        // Create a list of all selected filter values
        final selectedFilters = <String, List<String>>{};
        filters.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            selectedFilters[key] = value.cast<String>();
          }
        });

        // Find matching sections and their selected options
        final List<VenueResult> results = [];

        data.forEach((section) {
          final sectionSlug = section['slug'];
          if (selectedFilters.containsKey(sectionSlug)) {
            final selectedValues = selectedFilters[sectionSlug]!;

            final taxonomies = section['taxonomies'] as List;
            for (var taxonomy in taxonomies) {
              if (selectedValues.contains(taxonomy['slug'])) {
                results.add(VenueResult(
                  id: taxonomy['id'].toString(),
                  name: taxonomy['name'],
                  description: taxonomy[
                      'name'], // Using name as description since it's not in the data
                  image:
                      'https://example.com/placeholder.jpg', // Placeholder image
                  cuisines: [
                    taxonomy['name']
                  ], // Using the taxonomy name as cuisine
                  dietaryOptions: [],
                  location: section['name'],
                  rating: 4.5, // Default rating since it's not in the data
                ));
              }
            }
          }
        });

        // Sort results based on selected sort option
        final sortBy = filters['sort'] as String? ?? 'nearest_to_me';
        results.sort((a, b) {
          switch (sortBy) {
            case 'title_a_z':
              return a.name.compareTo(b.name);
            case 'newest_first':
              return -1; // Assuming newer items should be first
            case 'trending':
              return -1; // Assuming trending items should be first
            case 'nearest_to_me':
            default:
              return 0; // Keep original order
          }
        });

        return results;
      } else {
        throw Exception('Failed to load results');
      }
    } catch (e) {
      throw Exception('Error fetching results: $e');
    }
  }
}
