import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  final String? id;
  final String nombre;
  final String? descripcion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Categoria({
    this.id,
    required this.nombre,
    this.descripcion,
    this.createdAt,
    this.updatedAt,
  });

  // Crear desde JSON (Firestore DocumentSnapshot)
  factory Categoria.fromJson(Map<String, dynamic> json, [String? documentId]) {
    return Categoria(
      id: documentId,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      createdAt: json['createdAt'] != null 
        ? (json['createdAt'] as Timestamp).toDate()
        : null,
      updatedAt: json['updatedAt'] != null 
        ? (json['updatedAt'] as Timestamp).toDate()
        : null,
    );
  }

  // Crear desde DocumentSnapshot de Firestore
  factory Categoria.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Documento vacío');
    }
    return Categoria.fromJson(data, doc.id);
  }

  // Convertir a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convertir a JSON para actualización (sin createdAt)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copiar con nuevos valores
  Categoria copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Categoria{id: $id, nombre: $nombre, descripcion: $descripcion}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Categoria &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre;

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode;
}