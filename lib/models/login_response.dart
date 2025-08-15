class LoginResponse {
  final String token;

  LoginResponse({
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['token'] == null) {
      throw FormatException("الرمز المميز مفقود من الرد");
    }

    return LoginResponse(
      token: json['token'] as String,
    );
  }
}
