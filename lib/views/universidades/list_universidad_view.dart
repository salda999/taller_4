import 'package:flutter/material.dart';
import '../../widgets/custom_drawer.dart';
import '../../models/universidad.dart';
import '../../services/universidad_firebase_service.dart';
import 'create_universidad_view.dart';

class ListUniversidadesView extends StatefulWidget {
  const ListUniversidadesView({super.key});

  @override
  State<ListUniversidadesView> createState() => _ListUniversidadesViewState();
}

class _ListUniversidadesViewState extends State<ListUniversidadesView> {
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universidades')),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateUniversidad,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Universidad'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildUniversidadesList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.school,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Universidades',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                StreamBuilder<List<Universidad>>(
                  stream: UniversidadFirebaseService.watchUniversidades(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Total: ${snapshot.data!.length} universidades registradas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      );
                    }
                    return const Text('Cargando...');
                  },
                ),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _testConnection,
          icon: const Icon(Icons.wifi_protected_setup),
          tooltip: 'Probar conexión',
        ),
        IconButton(
          onPressed: _addSampleData,
          icon: const Icon(Icons.data_object),
          tooltip: 'Agregar datos de ejemplo',
        ),
        IconButton(
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refrescar',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar universidades por nombre...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchText = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() => _searchText = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildUniversidadesList() {
    return StreamBuilder<List<Universidad>>(
      stream: UniversidadFirebaseService.watchUniversidades(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // Filtrar universidades según búsqueda
        final universidades = snapshot.data!.where((universidad) {
          if (_searchText.isEmpty) return true;
          return universidad.nombre.toLowerCase().contains(_searchText) ||
                 universidad.nit.toLowerCase().contains(_searchText);
        }).toList();

        if (universidades.isEmpty) {
          return _buildNoResultsState();
        }

        return _buildUniversidadesGrid(universidades);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando universidades...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error al cargar universidades:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay universidades registradas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comience agregando la primera universidad',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateUniversidad,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Primera Universidad'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _addSampleData,
            icon: const Icon(Icons.data_object),
            label: const Text('Agregar Datos de Ejemplo'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intente con otros términos de búsqueda',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchText = '');
            },
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar Búsqueda'),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversidadesGrid(List<Universidad> universidades) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: universidades.length,
      itemBuilder: (context, index) {
        final universidad = universidades[index];
        return _buildUniversidadCard(universidad);
      },
    );
  }

  Widget _buildUniversidadCard(Universidad universidad) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: InkWell(
        onTap: () => _navigateToEditUniversidad(universidad),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          universidad.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIT: ${universidad.nit}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, universidad),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      universidad.direccion,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    universidad.telefono,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.language, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openWebsite(universidad.paginaWeb),
                      child: Text(
                        universidad.paginaWeb,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Universidad universidad) {
    switch (action) {
      case 'edit':
        _navigateToEditUniversidad(universidad);
        break;
      case 'delete':
        _showDeleteConfirmation(universidad);
        break;
    }
  }

  void _showDeleteConfirmation(Universidad universidad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro que desea eliminar la universidad "${universidad.nombre}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUniversidad(universidad);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUniversidad(Universidad universidad) async {
    try {
      await UniversidadFirebaseService.deleteUniversidad(universidad.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Universidad "${universidad.nombre}" eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToCreateUniversidad() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateUniversidadView(),
      ),
    );

    if (result == true && mounted) {
      // La universidad fue creada exitosamente
      setState(() {}); // Refrescar la vista
    }
  }

  Future<void> _navigateToEditUniversidad(Universidad universidad) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateUniversidadView(universidad: universidad),
      ),
    );

    if (result == true && mounted) {
      // La universidad fue editada exitosamente
      setState(() {}); // Refrescar la vista
    }
  }

  Future<void> _testConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Probando conexión a Firebase...')),
    );

    final connected = await UniversidadFirebaseService.testFirebaseConnection();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            connected
                ? '✅ Conexión exitosa a Firebase'
                : '❌ Error de conexión a Firebase',
          ),
          backgroundColor: connected ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _addSampleData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregando datos de ejemplo...')),
      );

      await UniversidadFirebaseService.agregarDatosEjemplo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Datos de ejemplo agregados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openWebsite(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrir: $url'),
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () {
            // Aquí podrías implementar copiar al portapapeles
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}