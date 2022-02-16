
class EmailSignInCredentials {
  final String email;
  final String password;

  EmailSignInCredentials({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  factory EmailSignInCredentials.fromJson(Map<String, dynamic> json) {
    return EmailSignInCredentials(email: json['email'], password: json['password']);
  }
}
