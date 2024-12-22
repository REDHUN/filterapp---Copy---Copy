class FilterOption {
  final String id;
  final String title;
  bool isSelected;

  FilterOption({
    required this.id,
    required this.title,
    this.isSelected = false,
  });
}
