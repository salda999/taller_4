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
  //* Se crea una instancia de la clase ComidasService
  final ComidasService _comidasService = ComidasService();
  //* Se declara una variable de tipo Future que contendrá la lista de Comidas
  late Future<List<Comida>> _futureComidas;

  @override
  void initState() {
    super.initState();
    //! Se llama al método getComidasByName de la clase ComidasService
    //! Usamos "Arrabiata" como término de búsqueda por defecto
    _futureComidas = _comidasService.getComidasByName('Arrabiata');
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Comidas - ListView',
      //! Se crea un FutureBuilder que se encargará de construir la lista de Comidas
      body: FutureBuilder<List<Comida>>(
        future: _futureComidas,
        builder: (context, snapshot) {
          //snapshot contiene la respuesta del Future
          if (snapshot.hasData) {
            //* Se obtiene la lista de Comidas
            final comidas = snapshot.data!;
            
            if (comidas.isEmpty) {
              return const Center(
                child: Text(
                  'No se encontraron comidas',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            
            //ListView.builder se utiliza para construir una lista de elementos de manera eficiente
            return ListView.builder(
              itemCount: comidas.length,
              itemBuilder: (context, index) {
                final comida = comidas[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  //* GestureDetector se utiliza para detectar gestos del usuario
                  //* en este caso se utiliza para navegar a la vista de detalle de la Comida
                  child: GestureDetector(
                    onTap: () {
                      context.push('/comidas/${comida.idMeal}');
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
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
                                    child: const Icon(
                                      Icons.restaurant,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comida.strMeal,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${comida.strCategory} • ${comida.strArea}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
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
