import 'package:flutter/material.dart';

import '../../models/comidas.dart';
import '../../services/comidas_service.dart';
import '../../widgets/base_view.dart';

class ComidasDetailView extends StatefulWidget {
  final String id;
  
  const ComidasDetailView({super.key, required this.id});

  @override
  State<ComidasDetailView> createState() => _ComidasDetailViewState();
}

class _ComidasDetailViewState extends State<ComidasDetailView> {
  final ComidasService _comidasService = ComidasService();
  late Future<Comida?> _futureComida;

  @override
  void initState() {
    super.initState();
    _futureComida = _comidasService.getComidaById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Detalle de Comida',
      body: FutureBuilder<Comida?>(
        future: _futureComida,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final comida = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de la comida
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        comida.strMealThumb,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nombre de la comida
                  Text(
                    comida.strMeal,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Categoría y área
                  Row(
                    children: [
                      Chip(
                        label: Text(comida.strCategory),
                        backgroundColor: Colors.blue[100],
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(comida.strArea),
                        backgroundColor: Colors.green[100],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ingredientes
                  if (comida.ingredients.isNotEmpty) ...[
                    const Text(
                      'Ingredientes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...comida.ingredients.asMap().entries.map((entry) {
                      int index = entry.key;
                      String ingredient = entry.value;
                      String measure = index < comida.measures.length ? comida.measures[index] : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text('• $measure $ingredient'),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Instrucciones
                  const Text(
                    'Instrucciones:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comida.strInstructions,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
