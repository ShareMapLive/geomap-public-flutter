class ApiResponse {
  int? code;
  int? statusCode;
  String? accessToken;
  String? role;
  dynamic error;
  dynamic message;
  dynamic data;

  ApiResponse({
    required this.code,
    this.accessToken,
    this.role,
    required this.statusCode,
    required this.error,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'],
      accessToken: json['access_token'] ?? "",
      role: json["role"] ?? "",
      statusCode: json['statusCode'],
      error: json['error'],
      message: json['message'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['statusCode'] = statusCode;
    data['error'] = error;
    data['access_token'] = accessToken;
    data['role'] = role;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data;
    }
    return data;
  }

  bool isSuccess() {
    return code == 1;
  }
}
