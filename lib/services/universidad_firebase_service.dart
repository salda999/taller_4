import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/universidad.dart';

class UniversidadFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _ref = _firestore.collection('universidades');

  // Método para probar la conexión a Firebase
  static Future<bool> testFirebaseConnection() async {
    try {
      debugPrint('🔍 Probando conexión a Firebase (universidades)...');
      
      // Intentar hacer una consulta simple
      final snapshot = await _ref.limit(1).get();
      debugPrint('✅ Conexión exitosa - Universidades encontradas: ${snapshot.docs.length}');
      return true;
    } catch (e) {
      debugPrint('❌ Error de conexión a Firebase: $e');
      return false;
    }
  }

  // Obtener todas las universidades como Stream (tiempo real)
  static Stream<List<Universidad>> watchUniversidades() {
    debugPrint('🎯 Iniciando stream de universidades...');
    
    return _ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        debugPrint('🔄 Stream actualizado - Documentos: ${snapshot.docs.length}');
        debugPrint('📊 Metadatos: fromCache=${snapshot.metadata.isFromCache}, hasPendingWrites=${snapshot.metadata.hasPendingWrites}');
        
        final universidades = <Universidad>[];
        
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            debugPrint('📄 Doc ID: ${doc.id}');
            debugPrint('📋 Data: $data');
            
            final universidad = Universidad.fromJson(data, doc.id);
            universidades.add(universidad);
            debugPrint('✅ Universidad procesada: ${universidad.nombre}');
          } catch (docError) {
            debugPrint('❌ Error procesando documento ${doc.id}: $docError');
          }
        }
        
        debugPrint('🎉 Stream procesado - Total universidades: ${universidades.length}');
        return universidades;
      } catch (e, stackTrace) {
        debugPrint('❌ Error crítico en stream: $e');
        debugPrint('📍 Stack trace: $stackTrace');
        return <Universidad>[];
      }
    }).handleError((error) {
      debugPrint('🚨 Error en stream de Firebase: $error');
      return <Universidad>[];
    });
  }

  // Obtener una universidad por ID
  static Future<Universidad?> getUniversidadById(String id) async {
    try {
      debugPrint('🔍 Obteniendo universidad ID: $id');
      final doc = await _ref.doc(id).get();
      if (doc.exists) {
        final universidad = Universidad.fromFirestore(doc);
        debugPrint('✅ Universidad encontrada: ${universidad.nombre}');
        return universidad;
      }
      debugPrint('⚠️ Universidad no encontrada');
      return null;
    } catch (e) {
      debugPrint('❌ Error al obtener universidad $id: $e');
      return null;
    }
  }

  // Crear nueva universidad
  static Future<String?> createUniversidad(Universidad universidad) async {
    try {
      debugPrint('➕ Creando universidad: ${universidad.nombre}');
      
      // Verificar si ya existe una universidad con el mismo NIT
      final existeNit = await existeUniversidadConNit(universidad.nit);
      if (existeNit) {
        throw Exception('Ya existe una universidad con el NIT ${universidad.nit}');
      }
      
      final docRef = await _ref.add(universidad.toJson());
      debugPrint('✅ Universidad creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error al crear universidad: $e');
      rethrow;
    }
  }

  // Actualizar universidad existente
  static Future<bool> updateUniversidad(String id, Universidad universidad) async {
    try {
      debugPrint('🔄 Actualizando universidad ID: $id');
      
      // Verificar si el NIT ya existe en otra universidad
      final existeNit = await existeUniversidadConNit(universidad.nit, excludeId: id);
      if (existeNit) {
        throw Exception('Ya existe otra universidad con el NIT ${universidad.nit}');
      }
      
      await _ref.doc(id).update(universidad.toJsonForUpdate());
      debugPrint('✅ Universidad $id actualizada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error al actualizar universidad $id: $e');
      rethrow;
    }
  }

  // Eliminar universidad
  static Future<bool> deleteUniversidad(String id) async {
    try {
      debugPrint('🗑️ Eliminando universidad ID: $id');
      await _ref.doc(id).delete();
      debugPrint('✅ Universidad $id eliminada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error al eliminar universidad $id: $e');
      rethrow;
    }
  }

  // Verificar si existe una universidad con el mismo NIT
  static Future<bool> existeUniversidadConNit(String nit, {String? excludeId}) async {
    try {
      debugPrint('🔍 Verificando NIT existente: $nit');
      
      final querySnapshot = await _ref
          .where('nit', isEqualTo: nit)
          .get();
      
      if (excludeId != null) {
        // Si estamos editando, excluir el ID actual
        final exists = querySnapshot.docs.any((doc) => doc.id != excludeId);
        debugPrint('📋 NIT existe (excluyendo $excludeId): $exists');
        return exists;
      }
      
      final exists = querySnapshot.docs.isNotEmpty;
      debugPrint('📋 NIT existe: $exists');
      return exists;
    } catch (e) {
      debugPrint('❌ Error verificando NIT: $e');
      return false;
    }
  }

  // Buscar universidades por nombre
  static Future<List<Universidad>> searchUniversidadesByNombre(String nombre) async {
    try {
      debugPrint('🔍 Buscando universidades por nombre: $nombre');
      
      final querySnapshot = await _ref
          .where('nombre', isGreaterThanOrEqualTo: nombre)
          .where('nombre', isLessThan: '${nombre}z')
          .get();

      final universidades = querySnapshot.docs
          .map((doc) => Universidad.fromFirestore(doc))
          .toList();
      
      debugPrint('📋 Universidades encontradas: ${universidades.length}');
      return universidades;
    } catch (e) {
      debugPrint('❌ Error buscando universidades: $e');
      return [];
    }
  }

  // Obtener conteo de universidades
  static Future<int> getUniversidadesCount() async {
    try {
      final snapshot = await _ref.get();
      final count = snapshot.docs.length;
      debugPrint('📊 Total universidades: $count');
      return count;
    } catch (e) {
      debugPrint('❌ Error contando universidades: $e');
      return 0;
    }
  }

  // Método para agregar datos de ejemplo (útil para testing)
  static Future<void> agregarDatosEjemplo() async {
    try {
      debugPrint('📝 Agregando universidades de ejemplo...');
      
      final universidades = [
        Universidad(
          nit: '890.123.456-7',
          nombre: 'UCEVA',
          direccion: 'Cra 27A #48-144, Tuluá - Valle',
          telefono: '+57 602 2242202',
          paginaWeb: 'https://www.uceva.edu.co',
        ),
        Universidad(
          nit: '860.007.394-1',
          nombre: 'Universidad Nacional de Colombia',
          direccion: 'Carrera 45 No 26-85, Bogotá',
          telefono: '+57 1 3165000',
          paginaWeb: 'https://unal.edu.co',
        ),
        Universidad(
          nit: '890.480.040-8',
          nombre: 'Universidad del Valle',
          direccion: 'Ciudad Universitaria Meléndez, Cali',
          telefono: '+57 602 3212100',
          paginaWeb: 'https://www.univalle.edu.co',
        ),
        Universidad(
          nit: '860.010.019-9',
          nombre: 'Universidad de los Andes',
          direccion: 'Carrera 1 No 18A-12, Bogotá',
          telefono: '+57 1 3394949',
          paginaWeb: 'https://uniandes.edu.co',
        ),
      ];

      for (final universidad in universidades) {
        // Verificar si ya existe antes de agregar
        final existe = await existeUniversidadConNit(universidad.nit);
        if (!existe) {
          await createUniversidad(universidad);
        } else {
          debugPrint('⚠️ Universidad ${universidad.nombre} ya existe, saltando...');
        }
      }
      
      debugPrint('✅ Datos de ejemplo agregados exitosamente');
    } catch (e) {
      debugPrint('❌ Error agregando datos de ejemplo: $e');
      rethrow;
    }
  }

  // Obtener universidad por NIT
  static Future<Universidad?> getUniversidadByNit(String nit) async {
    try {
      debugPrint('🔍 Buscando universidad por NIT: $nit');
      
      final querySnapshot = await _ref
          .where('nit', isEqualTo: nit)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final universidad = Universidad.fromFirestore(querySnapshot.docs.first);
        debugPrint('✅ Universidad encontrada por NIT: ${universidad.nombre}');
        return universidad;
      }
      
      debugPrint('⚠️ No se encontró universidad con NIT: $nit');
      return null;
    } catch (e) {
      debugPrint('❌ Error buscando por NIT: $e');
      return null;
    }
  }
}