import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/categoria.dart';

class CategoriaFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categorias';

  // Referencia a la colección
  CollectionReference get _categoriasRef => _firestore.collection(_collection);

  // Obtener todas las categorías como Stream (tiempo real)
  Stream<List<Categoria>> getCategorias() {
    try {
      return _categoriasRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            return Categoria.fromFirestore(doc);
          } catch (e) {
            debugPrint('Error al convertir documento ${doc.id}: $e');
            // Retornar categoría con datos básicos si hay error
            return Categoria(
              id: doc.id,
              nombre: 'Error al cargar',
              descripcion: 'Error en los datos',
            );
          }
        }).toList();
      });
    } catch (e) {
      debugPrint('Error al obtener categorías: $e');
      // Retornar stream vacío en caso de error
      return Stream.value(<Categoria>[]);
    }
  }

  // Obtener una categoría por ID
  Future<Categoria?> getCategoriaById(String id) async {
    try {
      final doc = await _categoriasRef.doc(id).get();
      if (doc.exists) {
        return Categoria.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener categoría $id: $e');
      return null;
    }
  }

  // Crear nueva categoría
  Future<String?> createCategoria(Categoria categoria) async {
    try {
      final docRef = await _categoriasRef.add(categoria.toJson());
      debugPrint('Categoría creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error al crear categoría: $e');
      throw Exception('Error al crear la categoría: $e');
    }
  }

  // Actualizar categoría existente
  Future<bool> updateCategoria(String id, Categoria categoria) async {
    try {
      await _categoriasRef.doc(id).update(categoria.toJsonForUpdate());
      debugPrint('Categoría $id actualizada exitosamente');
      return true;
    } catch (e) {
      debugPrint('Error al actualizar categoría $id: $e');
      throw Exception('Error al actualizar la categoría: $e');
    }
  }

  // Eliminar categoría
  Future<bool> deleteCategoria(String id) async {
    try {
      await _categoriasRef.doc(id).delete();
      debugPrint('Categoría $id eliminada exitosamente');
      return true;
    } catch (e) {
      debugPrint('Error al eliminar categoría $id: $e');
      throw Exception('Error al eliminar la categoría: $e');
    }
  }

  // Buscar categorías por nombre
  Future<List<Categoria>> searchCategoriasByNombre(String nombre) async {
    try {
      final querySnapshot = await _categoriasRef
          .where('nombre', isGreaterThanOrEqualTo: nombre)
          .where('nombre', isLessThan: '${nombre}z')
          .get();

      return querySnapshot.docs
          .map((doc) => Categoria.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error al buscar categorías: $e');
      return [];
    }
  }

  // Verificar si existe una categoría con el mismo nombre
  Future<bool> existeCategoriaNombre(String nombre, {String? excludeId}) async {
    try {
      Query query = _categoriasRef.where('nombre', isEqualTo: nombre);
      
      final querySnapshot = await query.get();
      
      if (excludeId != null) {
        // Si estamos editando, excluir el ID actual
        return querySnapshot.docs.any((doc) => doc.id != excludeId);
      }
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error al verificar nombre de categoría: $e');
      return false;
    }
  }

  // Obtener conteo de categorías
  Future<int> getCategoriasCount() async {
    try {
      final snapshot = await _categoriasRef.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error al contar categorías: $e');
      return 0;
    }
  }

  // Método para agregar datos de ejemplo (útil para testing)
  Future<void> addSampleData() async {
    final sampleCategorias = [
      Categoria(nombre: 'Tecnología', descripcion: 'Productos tecnológicos'),
      Categoria(nombre: 'Ropa', descripcion: 'Vestimenta y accesorios'),
      Categoria(nombre: 'Hogar', descripcion: 'Artículos para el hogar'),
      Categoria(nombre: 'Deportes', descripcion: 'Equipos y artículos deportivos'),
    ];

    for (final categoria in sampleCategorias) {
      // Verificar si ya existe antes de agregar
      final existe = await existeCategoriaNombre(categoria.nombre);
      if (!existe) {
        await createCategoria(categoria);
      }
    }
  }
}