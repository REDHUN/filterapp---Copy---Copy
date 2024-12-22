import 'filter_option.dart';

class FilterSection {
  final String title;
  final String slug;
  final List<FilterOption> options;
  final bool isExpanded;
  final int? selectedCount;

  FilterSection({
    required this.title,
    required this.slug,
    required this.options,
    this.isExpanded = false,
    this.selectedCount,
  });
}
