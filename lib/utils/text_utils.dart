import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

/// a special match validator to check if the input equals another provided value;
class MatchValidator extends TextFieldValidator {
  final TextEditingController valueToCompareController;

  MatchValidator({required String errorText, required this.valueToCompareController}) : super(errorText);

  bool _validateMatch(String value, String value2) {
    return value == value2;
  }

  @override
  bool isValid(String? value) {
    return _validateMatch(value ?? "", valueToCompareController.text);
  }
}
