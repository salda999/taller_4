import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_models.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'https://parking.visiontic.com.co/api';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Simulación de base de datos local
  static final List<Map<String, dynamic>> _localUsers = [];
  static int _nextUserId = 1;

  // Claves para SharedPreferences (datos no sensibles)
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _themeKey = 'app_theme';
  
  // Claves para FlutterSecureStorage (datos sensibles)
  static const String _tokenKey = 'access_token';

  // Login del usuario
  Future<LoginResponse?> login(LoginRequest loginRequest) async {
    try {
      // Primero intentar con la API real
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/login'),
          headers: {
            'Content-Type': 'application/json',
            'accept': '*/*',
            'X-CSRF-TOKEN': '',
          },
          body: json.encode(loginRequest.toJson()),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final loginResponse = LoginResponse.fromJson(json.decode(response.body));
          
          // Guardar token de forma segura
          await _saveToken(loginResponse.token);
          
          // Guardar datos del usuario en SharedPreferences
          await _saveUserData(loginResponse.user);
          
          return loginResponse;
        }
      } catch (e) {
        debugPrint('Error con API real, usando simulación local: $e');
      }

      // Si falla la API real, usar simulación local
      return await _loginLocal(loginRequest);
    } catch (e) {
      debugPrint('Error en login: $e');
      return null;
    }
  }

  // Login local (simulado)
  Future<LoginResponse?> _loginLocal(LoginRequest loginRequest) async {
    // Buscar usuario en la "base de datos" local
    final userMap = _localUsers.firstWhere(
      (user) => user['email'] == loginRequest.email && user['password'] == loginRequest.password,
      orElse: () => <String, dynamic>{},
    );

    if (userMap.isEmpty) {
      // Usuario no encontrado o contraseña incorrecta
      throw Exception('Credenciales incorrectas');
    }

    // Crear token simulado
    final fakeToken = 'fake_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    
    // Crear respuesta simulada
    final user = User.fromJson(userMap);
    final loginResponse = LoginResponse(
      success: true,
      token: fakeToken,
      type: 'bearer',
      expiresIn: 3600,
      user: user,
    );

    // Guardar token y datos
    await _saveToken(loginResponse.token);
    await _saveUserData(loginResponse.user);

    return loginResponse;
  }

  // Registro del usuario
  Future<RegisterResponse?> register(RegisterRequest registerRequest) async {
    try {
      debugPrint('Registrando usuario: ${registerRequest.toJson()}');
      
      // Primero intentar con la API real
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/users'),
          headers: {
            'Content-Type': 'application/json',
            'accept': '*/*',
            'X-CSRF-TOKEN': '',
          },
          body: json.encode(registerRequest.toJson()),
        ).timeout(const Duration(seconds: 10));

        debugPrint('Status code del registro: ${response.statusCode}');
        debugPrint('Respuesta del registro: ${response.body}');

        if (response.statusCode == 201) {
          final registerResponse = RegisterResponse.fromJson(json.decode(response.body));
          return registerResponse;
        } else {
          debugPrint('Error en registro: ${response.statusCode} - ${response.body}');
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error con API real, usando registro local: $e');
      }

      // Si falla la API real, usar registro local
      return await _registerLocal(registerRequest);
    } catch (e) {
      debugPrint('Error en registro: $e');
      rethrow;
    }
  }

  // Registro local (simulado)
  Future<RegisterResponse?> _registerLocal(RegisterRequest registerRequest) async {
    // Verificar si el email ya existe
    final existingUser = _localUsers.any((user) => user['email'] == registerRequest.email);
    if (existingUser) {
      throw Exception('El email ya está registrado');
    }

    // Crear nuevo usuario
    final newUser = {
      'id': _nextUserId++,
      'name': registerRequest.name,
      'email': registerRequest.email,
      'password': registerRequest.password, // En producción esto debería estar hasheado
      'email_verified_at': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Agregar a la "base de datos" local
    _localUsers.add(newUser);

    // Crear respuesta
    final user = User.fromJson(newUser);
    return RegisterResponse(
      success: true,
      message: 'Usuario creado correctamente (simulado)',
      data: user,
    );
  }

  // Guardar token de forma segura
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Obtener token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Guardar datos del usuario (no sensibles)
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, user.name);
    await prefs.setString(_emailKey, user.email);
  }

  // Obtener datos del usuario
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey),
      'email': prefs.getString(_emailKey),
      'theme': prefs.getString(_themeKey),
    };
  }

  // Verificar si el usuario está logueado
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Cerrar sesión
  Future<void> logout() async {
    // Eliminar token
    await _secureStorage.delete(key: _tokenKey);
    
    // Eliminar datos del usuario (pero mantener preferencias como tema)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
  }

  // Guardar tema de la aplicación
  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  // Obtener usuario por ID (simulado)
  Future<User?> getUserById(int userId) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      // Buscar en usuarios locales
      final userMap = _localUsers.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => <String, dynamic>{},
      );

      if (userMap.isNotEmpty) {
        return User.fromJson(userMap);
      }

      return null;
    } catch (e) {
      debugPrint('Error obteniendo usuario: $e');
      return null;
    }
  }
}