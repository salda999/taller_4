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

  // Claves para SharedPreferences (datos no sensibles)
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _themeKey = 'app_theme';
  
  // Claves para FlutterSecureStorage (datos sensibles)
  static const String _tokenKey = 'access_token';

  // Login del usuario
  Future<LoginResponse?> login(LoginRequest loginRequest) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'X-CSRF-TOKEN': '', // Como en el curl de ejemplo
        },
        body: json.encode(loginRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(json.decode(response.body));
        
        // Guardar token de forma segura
        await _saveToken(loginResponse.token);
        
        // Guardar datos del usuario en SharedPreferences
        await _saveUserData(loginResponse.user);
        
        return loginResponse;
      } else {
        debugPrint('Error en login: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      return null;
    }
  }

  // Registro del usuario
  Future<RegisterResponse?> register(RegisterRequest registerRequest) async {
    try {
      debugPrint('Registrando usuario: ${registerRequest.toJson()}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'X-CSRF-TOKEN': '', // Como en el curl de ejemplo
        },
        body: json.encode(registerRequest.toJson()),
      );

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
      debugPrint('Error en registro: $e');
      rethrow; // Propagar el error para que se muestre en la UI
    }
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

  // Obtener usuario por ID (para mostrar información adicional)
  Future<User?> getUserById(int userId) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        debugPrint('Error obteniendo usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error obteniendo usuario: $e');
      return null;
    }
  }
}