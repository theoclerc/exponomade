// Model for an object stored in a museum.
class Objet {
  final Map<String, String> chronologie;
  final String descriptionObjet;
  final String image;
  final String nomObjet;
  final String population;
  final List<String> raisons;

  Objet({
    required this.chronologie,
    required this.descriptionObjet,
    required this.image,
    required this.nomObjet,
    required this.population,
    required this.raisons,
  });
}
