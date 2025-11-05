import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/categoria_service.dart';

class FirebaseDebugView extends StatefulWidget {
  const FirebaseDebugView({super.key});

  @override
  State<FirebaseDebugView> createState() => _FirebaseDebugViewState();
}

class _FirebaseDebugViewState extends State<FirebaseDebugView> {
  String _status = 'Esperando prueba...';
  Color _statusColor = Colors.grey;
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Probando conexión...';
      _statusColor = Colors.orange;
    });

    try {
      final isConnected = await CategoriaService.testFirebaseConnection();
      
      if (isConnected) {
        // Si la conexión es exitosa, probar obtener datos
        final categorias = await CategoriaService.getCategorias();
        
        setState(() {
          _isLoading = false;
          if (categorias.isNotEmpty) {
            _status = '✅ Conexión OK - ${categorias.length} categorías encontradas';
            _statusColor = Colors.green;
          } else {
            _status = '⚠️ Conexión OK pero sin datos - Base de datos vacía';
            _statusColor = Colors.orange;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _status = '❌ Error de conexión con Firebase';
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '💥 Error: $e';
        _statusColor = Colors.red;
      });
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isLoading = true;
      _status = 'Creando datos de ejemplo...';
      _statusColor = Colors.blue;
    });

    try {
      await CategoriaService.agregarDatosEjemplo();
      setState(() {
        _isLoading = false;
        _status = '🎉 Datos de ejemplo creados exitosamente';
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '💥 Error creando datos: $e';
        _statusColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Firebase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de la Conexión',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Procesando...'),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          _status,
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acciones de Diagnóstico',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testConnection,
                        icon: const Icon(Icons.network_check),
                        label: const Text('Probar Conexión y Contar Datos'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createSampleData,
                        icon: const Icon(Icons.add_box),
                        label: const Text('Crear Datos de Ejemplo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/categoriasFirebase'),
                        icon: const Icon(Icons.list),
                        label: const Text('Ir a Lista de Categorías'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Si no aparecen datos, verifica las reglas de Firestore\n'
                      '• En Firebase Console ve a Firestore Database → Rules\n'
                      '• Para testing, usa: allow read, write: if true;\n'
                      '• Revisa la consola del navegador para logs detallados',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}