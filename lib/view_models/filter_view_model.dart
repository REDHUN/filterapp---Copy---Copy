import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/filter_section.dart';
import '../models/venue_result.dart';
import '../services/filter_service.dart';

class FilterViewModel extends ChangeNotifier {
  final FilterService _filterService;
  List<FilterSection> _sections = [];
  String _sortBy = 'nearest_to_me';
  bool _isLoading = false;
  String? _error;

  final Map<String, List<String>> _selectedFilters = {
    //  'cuisine': [],
    //'suitable-diet': [],
    // 'experience': [],
    ///  'mealperiod': [],
    // 'attire': [],
    // 'location': [],
    // 'pricerange': [],
  };

  List<FilterSection> get sections => _sections;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<String>> get selectedFilters => _selectedFilters;

  int get totalResults {
    int count = 0;
    _selectedFilters.forEach((key, value) => count += value.length);
    return count;
  }

  FilterViewModel({FilterService? filterService})
      : _filterService = filterService ?? FilterService() {
    fetchFilters();
  }

  Future<void> fetchFilters() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _sections = await _filterService.getFilters();
      notifyListeners();
    } catch (e) {
      if (e is SocketException) {
        _error = 'no_internet';
      } else {
        _error = 'An unexpected error occurred. Please try again.';
      }
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<VenueResult>> getFilteredResults() async {
    try {
      return await _filterService.getFilteredResults(getFiltersForApi());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void toggleOption(String sectionTitle, String optionId) {
    final sectionIndex = _sections.indexWhere((s) => s.title == sectionTitle);
    if (sectionIndex == -1) return;

    final section = _sections[sectionIndex];
    final optionIndex = section.options.indexWhere((o) => o.id == optionId);
    if (optionIndex == -1) return;

    _sections[sectionIndex].options[optionIndex].isSelected =
        !_sections[sectionIndex].options[optionIndex].isSelected;

    final sectionSlug = section.slug;
    if (_sections[sectionIndex].options[optionIndex].isSelected) {
      _selectedFilters[sectionSlug]?.add(optionId);
    } else {
      _selectedFilters[sectionSlug]?.remove(optionId);
    }

    notifyListeners();
  }

  // void setSortBy(String value) {
  //   switch (value) {
  //     case 'Nearest to Me (default)':
  //       _sortBy = 'nearest_to_me';
  //       break;
  //     case 'Trending this Week':
  //       _sortBy = 'trending';
  //       break;
  //     case 'Newest Added':
  //       _sortBy = 'newest_first';
  //       break;
  //     case 'Alphabetical':
  //       _sortBy = 'title_a_z';
  //       break;
  //     default:
  //       _sortBy = 'nearest_to_me';
  //   }
  //   notifyListeners();
  // }

  // String get sortByDisplay {
  //   switch (_sortBy) {
  //     case 'nearest_to_me':
  //       return 'Nearest to Me (default)';
  //     case 'trending':
  //       return 'Trending this Week';
  //     case 'newest_first':
  //       return 'Newest Added';
  //     case 'title_a_z':
  //       return 'Alphabetical';
  //     default:
  //       return 'Nearest to Me (default)';
  //   }
  // }

  Map<String, dynamic> getFiltersForApi() {
    final Map<String, dynamic> filters = {};

    _selectedFilters.forEach((key, value) {
      if (value.isNotEmpty) {
        filters[key] = value;
      }
    });

    filters['sort'] = _sortBy;

    return filters;
  }

  void clearFilters() {
    for (var section in _sections) {
      for (var option in section.options) {
        option.isSelected = false;
      }
    }

    _selectedFilters.forEach((key, value) => value.clear());
    notifyListeners();
  }

  void toggleSection(String sectionTitle) {
    final index = _sections.indexWhere((s) => s.title == sectionTitle);
    if (index == -1) return;

    _sections[index] = FilterSection(
      title: _sections[index].title,
      slug: _sections[index].slug,
      options: _sections[index].options,
      isExpanded: !_sections[index].isExpanded,
      selectedCount: _sections[index].selectedCount,
    );

    notifyListeners();
  }
}
