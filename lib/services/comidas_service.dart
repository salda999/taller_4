import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/comidas.dart';

//! El ComidasService es el encargado de hacer las peticiones a la API de TheMealDB
class ComidasService {
  // ! URL base de la API de TheMealDB
  static const String apiUrl = 'https://www.themealdb.com/api/json/v1/1';

  // ! Método para obtener comidas por nombre (búsqueda)
  // * Se hace una petición HTTP a la URL de la API y se obtiene la respuesta
  // * Si el estado de la respuesta es 200 se decodifica la respuesta y se obtiene la lista de comidas
  Future<List<Comida>> getComidasByName(String searchTerm) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/search.php?s=$searchTerm'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Si no hay resultados, la API retorna {"meals": null}
        if (data['meals'] == null) {
          return [];
        }

        final mealsResponse = MealsResponse.fromJson(data);
        return mealsResponse.meals;
      } else {
        throw Exception('Error al obtener las comidas. Código: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en getComidasByName: $e');
      }
      throw Exception('Error de conexión al buscar comidas: $e');
    }
  }

  // ! Método para obtener el detalle de una comida por ID
  Future<Comida?> getComidaById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Si no hay resultados, la API retorna {"meals": null}
        if (data['meals'] == null || data['meals'].isEmpty) {
          return null;
        }

        return Comida.fromJson(data['meals'][0]);
      } else {
        throw Exception('Error al obtener el detalle de la comida. Código: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en getComidaById: $e');
      }
      throw Exception('Error de conexión al obtener detalle de la comida: $e');
    }
  }

  // ! Método para obtener comidas por categoría
  Future<List<Comida>> getComidasByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['meals'] == null) {
          return [];
        }

        final mealsResponse = MealsResponse.fromJson(data);
        return mealsResponse.meals;
      } else {
        throw Exception('Error al obtener comidas por categoría. Código: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en getComidasByCategory: $e');
      }
      throw Exception('Error de conexión al buscar por categoría: $e');
    }
  }

  // ! Método para obtener una comida aleatoria
  Future<Comida?> getComidaAleatoria() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/random.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['meals'] == null || data['meals'].isEmpty) {
          return null;
        }

        return Comida.fromJson(data['meals'][0]);
      } else {
        throw Exception('Error al obtener comida aleatoria. Código: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en getComidaAleatoria: $e');
      }
      throw Exception('Error de conexión al obtener comida aleatoria: $e');
    }
  }
}