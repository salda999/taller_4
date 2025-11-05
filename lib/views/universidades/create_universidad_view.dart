import 'package:flutter/material.dart';
import '../../widgets/base_view.dart';
import '../../models/universidad.dart';
import '../../services/universidad_firebase_service.dart';

class CreateUniversidadView extends StatefulWidget {
  final Universidad? universidad; // Para edición
  
  const CreateUniversidadView({super.key, this.universidad});

  @override
  State<CreateUniversidadView> createState() => _CreateUniversidadViewState();
}

class _CreateUniversidadViewState extends State<CreateUniversidadView> {
  final _formKey = GlobalKey<FormState>();
  final _nitController = TextEditingController();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _paginaWebController = TextEditingController();
  
  bool _isLoading = false;
  bool get _isEditing => widget.universidad != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nitController.text = widget.universidad!.nit;
      _nombreController.text = widget.universidad!.nombre;
      _direccionController.text = widget.universidad!.direccion;
      _telefonoController.text = widget.universidad!.telefono;
      _paginaWebController.text = widget.universidad!.paginaWeb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: _isEditing ? 'Editar Universidad' : 'Nueva Universidad',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildFormCard(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  _isEditing ? 'Modificar información' : 'Nueva universidad',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Complete todos los campos obligatorios con información válida.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNitField(),
            const SizedBox(height: 16),
            _buildNombreField(),
            const SizedBox(height: 16),
            _buildDireccionField(),
            const SizedBox(height: 16),
            _buildTelefonoField(),
            const SizedBox(height: 16),
            _buildPaginaWebField(),
          ],
        ),
      ),
    );
  }

  Widget _buildNitField() {
    return TextFormField(
      controller: _nitController,
      decoration: InputDecoration(
        labelText: 'NIT *',
        hintText: 'Ej: 890.123.456-7',
        prefixIcon: const Icon(Icons.business),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        helperText: 'Formato: XXX.XXX.XXX-X',
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El NIT es obligatorio';
        }
        final nitError = Universidad.validateNit(value);
        return nitError;
      },
      onChanged: (value) {
        // Auto-format NIT while typing
        if (value.isNotEmpty && !value.contains('.') && !value.contains('-')) {
          if (value.length >= 3) {
            String formatted = value;
            if (value.length >= 6) {
              formatted = '${value.substring(0, 3)}.${value.substring(3, 6)}';
              if (value.length >= 9) {
                formatted += '.${value.substring(6, 9)}';
                if (value.length >= 10) {
                  formatted += '-${value.substring(9)}';
                }
              }
            }
            if (formatted != value) {
              _nitController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          }
        }
      },
    );
  }

  Widget _buildNombreField() {
    return TextFormField(
      controller: _nombreController,
      decoration: InputDecoration(
        labelText: 'Nombre de la Universidad *',
        hintText: 'Ej: Universidad del Valle',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El nombre es obligatorio';
        }
        if (value.length < 3) {
          return 'El nombre debe tener al menos 3 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildDireccionField() {
    return TextFormField(
      controller: _direccionController,
      decoration: InputDecoration(
        labelText: 'Dirección *',
        hintText: 'Ej: Carrera 45 No 26-85, Bogotá',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.words,
      maxLines: 2,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La dirección es obligatoria';
        }
        if (value.length < 10) {
          return 'La dirección debe ser más específica';
        }
        return null;
      },
    );
  }

  Widget _buildTelefonoField() {
    return TextFormField(
      controller: _telefonoController,
      decoration: InputDecoration(
        labelText: 'Teléfono *',
        hintText: 'Ej: +57 602 2242202',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        helperText: 'Incluir código de país (+57)',
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El teléfono es obligatorio';
        }
        final telefonoError = Universidad.validateTelefono(value);
        return telefonoError;
      },
      onChanged: (value) {
        // Auto-add +57 if not present and starts with numbers
        if (value.isNotEmpty && !value.startsWith('+') && RegExp(r'^\d').hasMatch(value)) {
          _telefonoController.value = TextEditingValue(
            text: '+57 $value',
            selection: TextSelection.collapsed(offset: value.length + 4),
          );
        }
      },
    );
  }

  Widget _buildPaginaWebField() {
    return TextFormField(
      controller: _paginaWebController,
      decoration: InputDecoration(
        labelText: 'Página Web *',
        hintText: 'Ej: https://www.universidad.edu.co',
        prefixIcon: const Icon(Icons.language),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        helperText: 'URL completa incluyendo https://',
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La página web es obligatoria';
        }
        final urlError = Universidad.validatePaginaWeb(value);
        return urlError;
      },
      onChanged: (value) {
        // Auto-add https:// if not present
        if (value.isNotEmpty && !value.startsWith('http') && value.contains('.')) {
          _paginaWebController.value = TextEditingValue(
            text: 'https://$value',
            selection: TextSelection.collapsed(offset: value.length + 8),
          );
        }
      },
    );
  }

  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveUniversidad,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(
                  _isLoading
                      ? 'Guardando...'
                      : _isEditing
                          ? 'Actualizar Universidad'
                          : 'Crear Universidad',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton.icon(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUniversidad() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor corrija los errores en el formulario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final universidad = Universidad(
        id: _isEditing ? widget.universidad!.id : null,
        nit: _nitController.text.trim(),
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        paginaWeb: _paginaWebController.text.trim(),
      );

      if (_isEditing) {
        await UniversidadFirebaseService.updateUniversidad(
          widget.universidad!.id!,
          universidad,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Universidad actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final id = await UniversidadFirebaseService.createUniversidad(universidad);
        
        if (mounted && id != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Universidad creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // true indica que se guardó exitosamente
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nitController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _paginaWebController.dispose();
    super.dispose();
  }
}