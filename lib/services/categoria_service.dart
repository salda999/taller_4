import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/categoria_fb.dart';

class CategoriaService {
  static final _firestore = FirebaseFirestore.instance;
  static final _ref = _firestore.collection('categorias');

  // Método para probar la conexión a Firebase
  static Future<bool> testFirebaseConnection() async {
    try {
      debugPrint('🔍 Probando conexión a Firebase...');
      
      // Intentar hacer una consulta simple
      final snapshot = await _ref.limit(1).get();
      debugPrint('✅ Conexión exitosa - Documentos encontrados: ${snapshot.docs.length}');
      return true;
    } catch (e) {
      debugPrint('❌ Error de conexión a Firebase: $e');
      return false;
    }
  }

  static Stream<CategoriaFb?> watchCategoriaById(String id) {
    return _ref.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return CategoriaFb.fromMap(doc.id, doc.data()!);
      }
      return null;
    });
  }

  /// Obtiene todas las categorías
  static Future<List<CategoriaFb>> getCategorias() async {
    try {
      print('🔍 Intentando obtener categorías de Firebase...');
      final snapshot = await _ref.get();
      print('📊 Documentos encontrados: ${snapshot.docs.length}');
      
      final categorias = snapshot.docs
          .map((doc) => CategoriaFb.fromMap(doc.id, doc.data()))
          .toList();
      
      print('✅ Categorías procesadas: ${categorias.length}');
      return categorias;
    } catch (e) {
      print('❌ Error al obtener categorías: $e');
      rethrow;
    }
  }

  /// Agrega una nueva categoría
  static Future<void> addCategoria(CategoriaFb categoria) async {
    try {
      print('➕ Creando categoría: ${categoria.nombre}');
      final docRef = await _ref.add(categoria.toMap());
      print('✅ Categoría creada con ID: ${docRef.id}');
    } catch (e) {
      print('❌ Error al crear categoría: $e');
      rethrow;
    }
  }

  /// Actualiza una categoría existente
  static Future<void> updateCategoria(CategoriaFb categoria) async {
    await _ref.doc(categoria.id).update(categoria.toMap());
  }

  /// Obtiene una categoría por su ID
  static Future<CategoriaFb?> getCategoriaById(String id) async {
    final doc = await _ref.doc(id).get();
    if (doc.exists) {
      return CategoriaFb.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  /// Elimina una categoría
  static Future<void> deleteCategoria(String id) async {
    await _ref.doc(id).delete();
  }

  //!/ Observa los cambios en la colección de categorías
  /// y devuelve una lista de categorías actualizada
  static Stream<List<CategoriaFb>> watchCategorias() {
    debugPrint('🎯 Iniciando stream de categorías...');
    
    return _ref.snapshots().map((snapshot) {
      try {
        debugPrint('🔄 Stream actualizado - Documentos: ${snapshot.docs.length}');
        debugPrint('📊 Metadatos: fromCache=${snapshot.metadata.isFromCache}, hasPendingWrites=${snapshot.metadata.hasPendingWrites}');
        
        final categorias = <CategoriaFb>[];
        
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            debugPrint('📄 Doc ID: ${doc.id}');
            debugPrint('📋 Data: $data');
            
            final categoria = CategoriaFb.fromMap(doc.id, data);
            categorias.add(categoria);
            debugPrint('✅ Categoría procesada: ${categoria.nombre}');
          } catch (docError) {
            debugPrint('❌ Error procesando documento ${doc.id}: $docError');
          }
        }
        
        debugPrint('🎉 Stream procesado - Total categorías: ${categorias.length}');
        return categorias;
      } catch (e, stackTrace) {
        debugPrint('❌ Error crítico en stream: $e');
        debugPrint('📍 Stack trace: $stackTrace');
        return <CategoriaFb>[];
      }
    }).handleError((error) {
      debugPrint('🚨 Error en stream de Firebase: $error');
      return <CategoriaFb>[];
    });
  }

  /// Agrega datos de ejemplo para testing
  static Future<void> agregarDatosEjemplo() async {
    try {
      print('📝 Agregando datos de ejemplo...');
      
      final categorias = [
        CategoriaFb(id: '', nombre: 'Tecnología', descripcion: 'Productos y servicios tecnológicos'),
        CategoriaFb(id: '', nombre: 'Educación', descripcion: 'Cursos, libros y material educativo'),
        CategoriaFb(id: '', nombre: 'Deportes', descripcion: 'Equipos y actividades deportivas'),
        CategoriaFb(id: '', nombre: 'Alimentación', descripcion: 'Comidas y bebidas'),
      ];

      for (final categoria in categorias) {
        await addCategoria(categoria);
      }
      
      print('✅ Datos de ejemplo agregados exitosamente');
    } catch (e) {
      print('❌ Error al agregar datos de ejemplo: $e');
      rethrow;
    }
  }
}
