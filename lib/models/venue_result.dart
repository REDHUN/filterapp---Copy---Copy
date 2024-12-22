class VenueResult {
  final String id;
  final String name;
  final String description;
  final String image;
  final List<String> cuisines;
  final List<String> dietaryOptions;
  final String location;
  final double rating;

  VenueResult({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.cuisines,
    required this.dietaryOptions,
    required this.location,
    required this.rating,
  });
}
