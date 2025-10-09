/// Modelo para representar una comida con sus propiedades principales
class Comida {
  String idMeal;
  String strMeal;
  String? strMealAlternate;
  String strCategory;
  String strArea;
  String strInstructions;
  String strMealThumb;
  String? strTags;
  String? strYoutube;
  List<String> ingredients;
  List<String> measures;
  String? strSource;
  String? strImageSource;
  String? strCreativeCommonsConfirmed;
  String? dateModified;

  // Constructor de la clase Comida con los atributos requeridos
  Comida({
    required this.idMeal,
    required this.strMeal,
    this.strMealAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    this.strTags,
    this.strYoutube,
    required this.ingredients,
    required this.measures,
    this.strSource,
    this.strImageSource,
    this.strCreativeCommonsConfirmed,
    this.dateModified,
  });

  // Factory method para convertir un JSON en una instancia de Comida
  factory Comida.fromJson(Map<String, dynamic> json) {
    // Procesar ingredientes y medidas (solo los que no están vacíos)
    List<String> ingredients = [];
    List<String> measures = [];
    
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.isNotEmpty && ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure ?? '');
      }
    }

    return Comida(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strMealAlternate: json['strMealAlternate'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      strTags: json['strTags'],
      strYoutube: json['strYoutube'],
      ingredients: ingredients,
      measures: measures,
      strSource: json['strSource'],
      strImageSource: json['strImageSource'],
      strCreativeCommonsConfirmed: json['strCreativeCommonsConfirmed'],
      dateModified: json['dateModified'],
    );
  }
}

/// Modelo para representar la respuesta completa de la API
class MealsResponse {
  List<Comida> meals;

  MealsResponse({required this.meals});

  factory MealsResponse.fromJson(Map<String, dynamic> json) {
    return MealsResponse(
      meals: (json['meals'] as List<dynamic>?)
              ?.map((meal) => Comida.fromJson(meal))
              .toList() ??
          [],
    );
  }
}