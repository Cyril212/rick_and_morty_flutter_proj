import 'package:json_annotation/json_annotation.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

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
