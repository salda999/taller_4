import 'package:cloud_firestore/cloud_firestore.dart';

class Universidad {
  final String? id;
  final String nit;
  final String nombre;
  final String direccion;
  final String telefono;
  final String paginaWeb;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Universidad({
    this.id,
    required this.nit,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.paginaWeb,
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde JSON (Firestore DocumentSnapshot)
  factory Universidad.fromJson(Map<String, dynamic> json, [String? documentId]) {
    return Universidad(
      id: documentId,
      nit: json['nit'] ?? '',
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      paginaWeb: json['pagina_web'] ?? '',
      createdAt: json['createdAt'] != null 
        ? (json['createdAt'] as Timestamp).toDate()
        : null,
      updatedAt: json['updatedAt'] != null 
        ? (json['updatedAt'] as Timestamp).toDate()
        : null,
    );
  }

  // Crear desde DocumentSnapshot de Firestore
  factory Universidad.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Documento vacío');
    }
    return Universidad.fromJson(data, doc.id);
  }

  // Convertir a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'nit': nit,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'pagina_web': paginaWeb,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convertir a JSON para actualización (sin createdAt)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'nit': nit,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'pagina_web': paginaWeb,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copiar con nuevos valores
  Universidad copyWith({
    String? id,
    String? nit,
    String? nombre,
    String? direccion,
    String? telefono,
    String? paginaWeb,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Universidad(
      id: id ?? this.id,
      nit: nit ?? this.nit,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      paginaWeb: paginaWeb ?? this.paginaWeb,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Validaciones
  static String? validateNit(String? nit) {
    if (nit == null || nit.trim().isEmpty) {
      return 'El NIT es requerido';
    }
    // Validación básica de formato NIT colombiano
    final nitPattern = RegExp(r'^\d{9,10}-?\d$');
    if (!nitPattern.hasMatch(nit.replaceAll('.', '').replaceAll(' ', ''))) {
      return 'NIT debe tener formato válido (ej: 890123456-7)';
    }
    return null;
  }

  static String? validateNombre(String? nombre) {
    if (nombre == null || nombre.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (nombre.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateDireccion(String? direccion) {
    if (direccion == null || direccion.trim().isEmpty) {
      return 'La dirección es requerida';
    }
    if (direccion.trim().length < 10) {
      return 'La dirección debe tener al menos 10 caracteres';
    }
    return null;
  }

  static String? validateTelefono(String? telefono) {
    if (telefono == null || telefono.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    // Validación básica para teléfonos colombianos
    final telefonoPattern = RegExp(r'^\+?57\s?[0-9\s\-\(\)]{8,15}$');
    if (!telefonoPattern.hasMatch(telefono.replaceAll(' ', ''))) {
      return 'Teléfono debe ser válido (ej: +57 602 2242202)';
    }
    return null;
  }

  static String? validatePaginaWeb(String? paginaWeb) {
    if (paginaWeb == null || paginaWeb.trim().isEmpty) {
      return 'La página web es requerida';
    }
    
    // Validación de URL
    try {
      final uri = Uri.parse(paginaWeb);
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return 'URL debe comenzar con http:// o https://';
      }
      if (uri.host.isEmpty) {
        return 'URL debe tener un dominio válido';
      }
      return null;
    } catch (e) {
      return 'URL no válida';
    }
  }

  @override
  String toString() {
    return 'Universidad{id: $id, nombre: $nombre, nit: $nit}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Universidad &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nit == other.nit;

  @override
  int get hashCode => id.hashCode ^ nit.hashCode;
}