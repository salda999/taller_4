# Taller 4 - Consumo de API REST con Flutter

## 📋 Descripción del Proyecto

Este proyecto implementa una aplicación Flutter que consume la API REST de **TheMealDB** para mostrar información sobre comidas. La aplicación demuestra el consumo de APIs, navegación con rutas nombradas, manejo de estados y buenas prácticas de desarrollo en Flutter.

## 🎯 Objetivos del Taller

### Requisitos Implementados:

1. **✅ Consumo de API y Listado**
   - Consumo de API REST usando HTTP GET
   - Renderizado de resultados con ListView.builder
   - Manejo de imágenes de la API
   - Estados de carga, éxito y error

2. **✅ Detalle con navegación (go_router)**
   - Navegación a pantalla de detalle con parámetros
   - Uso de rutas nombradas con go_router
   - Información ampliada en la vista de detalle

3. **✅ Manejo de estado y validación**
   - Try/catch para manejo de errores
   - Verificación de statusCode HTTP
   - Estados de UI (loading/success/error)

4. **✅ Buenas prácticas**
   - Separación de lógica en services
   - Uso de modelos con fromJson
   - Peticiones en initState()
   - Future/async/await correctamente implementado

## 🚀 API Utilizada

**TheMealDB API**
- URL Base: `https://www.themealdb.com/api/json/v1/1`
- Endpoint principal: `/search.php?s=Arrabiata`

### Ejemplo de respuesta JSON:
```json
{
  "meals": [
    {
      "idMeal": "52771",
      "strMeal": "Spicy Arrabiata Penne",
      "strCategory": "Vegetarian",
      "strArea": "Italian",
      "strInstructions": "Bring a large pot of water to a boil...",
      "strMealThumb": "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
      "strIngredient1": "penne rigate",
      "strMeasure1": "1 pound",
      // ... más ingredientes y medidas
    }
  ]
}
```

## 🏗️ Arquitectura del Proyecto

```
lib/
├── models/
│   └── comidas.dart          # Modelos de datos
├── services/
│   └── comidas_service.dart  # Lógica de API
├── views/
│   └── comidas/
│       ├── comidas_list_view.dart    # Lista de comidas
│       └── comidas_detail_view.dart  # Detalle de comida
├── routes/
│   └── app_router.dart       # Configuración de rutas
└── widgets/
    ├── base_view.dart        # Vista base con drawer
    └── custom_drawer.dart    # Menú lateral
```

## 💻 Código Implementado

### 1. Modelo de Datos (`models/comidas.dart`)

```dart
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
  // ... más propiedades

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
    // ... más parámetros
  });

  /// Factory method para convertir JSON en instancia de Comida
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
    );
  }
}

/// Modelo para la respuesta completa de la API
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
```

### 2. Servicio HTTP (`services/comidas_service.dart`)

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/comidas.dart';

/// Service para manejar las peticiones HTTP a TheMealDB API
class ComidasService {
  static const String apiUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Método para obtener comidas por nombre (búsqueda)
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

  /// Método para obtener el detalle de una comida por ID
  Future<Comida?> getComidaById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
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

  // ... más métodos (por categoría, aleatorio, etc.)
}
```

### 3. Vista de Lista (`views/comidas/comidas_list_view.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/comidas.dart';
import '../../services/comidas_service.dart';
import '../../widgets/base_view.dart';

class ComidasListView extends StatefulWidget {
  const ComidasListView({super.key});

  @override
  State<ComidasListView> createState() => _ComidasListViewState();
}

class _ComidasListViewState extends State<ComidasListView> {
  final ComidasService _comidasService = ComidasService();
  late Future<List<Comida>> _futureComidas;

  @override
  void initState() {
    super.initState();
    // Realizar petición HTTP en initState (buena práctica)
    _futureComidas = _comidasService.getComidasByName('Arrabiata');
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Comidas - ListView',
      body: FutureBuilder<List<Comida>>(
        future: _futureComidas,
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Estado de error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                ],
              ),
            );
          }
          
          // Estado de éxito
          if (snapshot.hasData) {
            final comidas = snapshot.data!;
            
            if (comidas.isEmpty) {
              return const Center(
                child: Text('No se encontraron comidas', style: TextStyle(fontSize: 18)),
              );
            }
            
            // ListView.builder para renderizar eficientemente
            return ListView.builder(
              itemCount: comidas.length,
              itemBuilder: (context, index) {
                final comida = comidas[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navegación con parámetros usando go_router
                      context.push('/comidas/${comida.idMeal}');
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Imagen de la comida
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                comida.strMealThumb,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            // Información de la comida
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comida.strMeal,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${comida.strCategory} • ${comida.strArea}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

### 4. Configuración de Rutas (`routes/app_router.dart`)

```dart
import 'package:go_router/go_router.dart';
// ... otros imports
import '../views/comidas/comidas_detail_view.dart';
import '../views/comidas/comidas_list_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    // ... otras rutas existentes
    
    // Ruta principal para la lista de comidas
    GoRoute(
      path: '/comidas',
      name: 'comidas',
      builder: (context, state) => const ComidasListView(),
    ),
    
    // Ruta para el detalle de comidas con parámetro ID
    GoRoute(
      path: '/comidas/:id',
      name: 'comidas_detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ComidasDetailView(id: id);
      },
    ),
  ],
);
```

### 5. Menú de Navegación (`widgets/custom_drawer.dart`)

```dart
// Agregar entrada en el menú
ListTile(
  leading: const Icon(Icons.restaurant),
  title: const Text('COMIDAS'),
  onTap: () {
    context.go('/comidas');
    Navigator.pop(context); // Cierra el drawer
  },
),
```

## 🔧 Características Técnicas

### Manejo de Estados
- **Loading**: CircularProgressIndicator mientras se cargan los datos
- **Success**: Lista de comidas con imágenes y navegación
- **Error**: Mensaje de error amigable con icono

### Manejo de Errores
- Try/catch en todas las peticiones HTTP
- Verificación de statusCode (200 = éxito)
- Fallback para imágenes que no cargan
- Mensajes de error descriptivos

### Navegación
- **go_router** para navegación declarativa
- Rutas con parámetros (`/comidas/:id`)
- Rutas nombradas para mejor organización
- Navegación hacia atrás automática

### Buenas Prácticas Implementadas
- ✅ Separación de responsabilidades (Service/Model/View)
- ✅ Peticiones HTTP en `initState()` no en `build()`
- ✅ Uso de `Future`/`async`/`await`
- ✅ Manejo de nullability en Dart
- ✅ Error handling con try/catch
- ✅ Loading states para mejor UX
- ✅ Código limpio y comentado

## 🚦 Cómo Ejecutar

1. **Clonar el repositorio**
```bash
git clone [url-del-repositorio]
cd parqueadero_2025_g2
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
# En Windows
flutter run -d windows

# En navegador web
flutter run -d chrome
# o
flutter run -d edge
```

## 📱 Funcionalidades

1. **Lista de Comidas**: Muestra comidas obtenidas de la API con imagen, nombre, categoría y origen
2. **Detalle de Comida**: Vista expandida con ingredientes, instrucciones y imagen grande
3. **Navegación**: Menú lateral para acceder a diferentes secciones
4. **Estados de UI**: Indicadores de carga y manejo de errores
5. **Responsive**: Funciona en web, desktop y móvil

## 🧪 Testing

La aplicación incluye manejo robusto de errores:
- Conexión de red
- Respuestas HTTP inválidas
- Datos malformados
- Imágenes que no cargan

## 📊 Estructura de Datos

La aplicación maneja eficientemente:
- **20 ingredientes** posibles por comida
- **20 medidas** correspondientes
- **Filtrado automático** de campos vacíos
- **Conversión JSON** robusta con validaciones

## 🔗 APIs Utilizadas

- **TheMealDB**: API gratuita de recetas y comidas
- **Endpoints implementados**:
  - `GET /search.php?s={term}` - Búsqueda por nombre
  - `GET /lookup.php?i={id}` - Obtener por ID
  - Soporte para filtros por categoría y comida aleatoria

---

**Desarrollado como parte del Taller 4 - Consumo de API REST con Flutter**  
*Universidad UCEVA - 2025*
