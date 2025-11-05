import 'package:flutter/material.dart';
import '../../widgets/base_view.dart';
import '../../models/universidad.dart';
import '../../services/universidad_firebase_service.dart';

class UniversidadEvidenciaView extends StatefulWidget {
  const UniversidadEvidenciaView({super.key});

  @override
  State<UniversidadEvidenciaView> createState() => _UniversidadEvidenciaViewState();
}

class _UniversidadEvidenciaViewState extends State<UniversidadEvidenciaView> {
  int _totalUniversidades = 0;
  bool _isConnected = false;
  List<String> _logMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _testInitialConnection();
    _startListening();
  }

  void _addLog(String message) {
    setState(() {
      _logMessages.add('${DateTime.now().toIso8601String()}: $message');
    });
    // Auto scroll al final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _testInitialConnection() async {
    _addLog('🔍 Probando conexión inicial a Firebase...');
    final connected = await UniversidadFirebaseService.testFirebaseConnection();
    setState(() {
      _isConnected = connected;
    });
    _addLog(connected ? '✅ Conexión exitosa' : '❌ Error de conexión');
  }

  void _startListening() {
    _addLog('🎧 Iniciando escucha en tiempo real...');
    
    UniversidadFirebaseService.watchUniversidades().listen(
      (universidades) {
        _addLog('📡 Actualización recibida: ${universidades.length} universidades');
        setState(() {
          _totalUniversidades = universidades.length;
        });
        
        for (var universidad in universidades) {
          _addLog('📋 ${universidad.nombre} (${universidad.nit})');
        }
      },
      onError: (error) {
        _addLog('❌ Error en stream: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Evidencia - Universidad Firebase',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildRealTimeDemo(),
            const SizedBox(height: 16),
            _buildActionsCard(),
            const SizedBox(height: 16),
            _buildLogCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  'Estado de Conexión',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isConnected ? '🟢 Conectado a Firebase' : '🔴 Desconectado',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Colección: universidades',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.school,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Universidades',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '$_totalUniversidades',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Actualizando en tiempo real',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Demostración en Tiempo Real',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta vista se actualiza automáticamente cuando se agregan, modifican o eliminan universidades desde cualquier dispositivo conectado.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: StreamBuilder<List<Universidad>>(
                stream: UniversidadFirebaseService.watchUniversidades(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Conectando al stream...'),
                      ],
                    );
                  }

                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text('Error: ${snapshot.error}'),
                      ],
                    );
                  }

                  final universidades = snapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stream, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Text('Stream activo: ${universidades.length} elementos'),
                        ],
                      ),
                      if (universidades.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Última universidad: ${universidades.first.nombre}'),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎮 Acciones de Prueba',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _testConnection,
                  icon: const Icon(Icons.wifi_protected_setup),
                  label: const Text('Test Conexión'),
                ),
                ElevatedButton.icon(
                  onPressed: _addSampleData,
                  icon: const Icon(Icons.data_object),
                  label: const Text('Agregar Ejemplo'),
                ),
                ElevatedButton.icon(
                  onPressed: _createTestUniversity,
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Test'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 Log de Actividad',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _logMessages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _logMessages[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    _addLog('🔍 Ejecutando test de conexión...');
    final connected = await UniversidadFirebaseService.testFirebaseConnection();
    setState(() {
      _isConnected = connected;
    });
    _addLog(connected ? '✅ Test exitoso' : '❌ Test fallido');
  }

  Future<void> _addSampleData() async {
    try {
      _addLog('📝 Agregando datos de ejemplo...');
      await UniversidadFirebaseService.agregarDatosEjemplo();
      _addLog('✅ Datos de ejemplo agregados');
    } catch (e) {
      _addLog('❌ Error agregando datos: $e');
    }
  }

  Future<void> _createTestUniversity() async {
    try {
      _addLog('🏗️ Creando universidad de prueba...');
      
      final testUniversidad = Universidad(
        nit: '${DateTime.now().millisecondsSinceEpoch}'.substring(7) + '-${DateTime.now().second}',
        nombre: 'Universidad Test ${DateTime.now().second}',
        direccion: 'Dirección de prueba ${DateTime.now().minute}',
        telefono: '+57 300 ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        paginaWeb: 'https://test${DateTime.now().second}.edu.co',
      );

      final id = await UniversidadFirebaseService.createUniversidad(testUniversidad);
      _addLog('✅ Universidad test creada con ID: $id');
    } catch (e) {
      _addLog('❌ Error creando test: $e');
    }
  }

  void _clearLogs() {
    setState(() {
      _logMessages.clear();
    });
    _addLog('🧹 Log limpiado');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}