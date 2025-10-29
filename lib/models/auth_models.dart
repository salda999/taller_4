import 'user.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final bool success;
  final String token;
  final String type;
  final int expiresIn;
  final User user;

  LoginResponse({
    required this.success,
    required this.token,
    required this.type,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      token: json['token'],
      type: json['type'],
      expiresIn: json['expires_in'],
      user: User.fromJson(json['user']),
    );
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}

class RegisterResponse {
  final bool success;
  final String message;
  final User data;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'],
      message: json['message'],
      data: User.fromJson(json['data']),
    );
  }
}