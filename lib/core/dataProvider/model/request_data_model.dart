import 'package:flutter/material.dart';

abstract class RequestDataModel {

  RequestDataModel();
  /// Covert the object into JSON map
  Map<String, dynamic> toJson();
}
