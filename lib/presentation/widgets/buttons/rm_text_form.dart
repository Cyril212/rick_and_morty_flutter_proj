import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart' as validator;
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/utils/text_utils.dart';

class RMTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final EdgeInsets _padding;

  final InputDecoration? _decoration;
  final FormFieldValidator<String>? _validator;
  final bool _isObscuredText;

  ///Default constructor
  const RMTextFormField._({Key? key, required this.controller, value, padding, FormFieldValidator<String>? validator, decoration, isObscuredText})
      : _padding = padding ?? const EdgeInsets.only(left: 40.0, right: 40.0, top: 24, bottom: 0),
        _validator = validator,
        _decoration = decoration ?? const InputDecoration(),
        _isObscuredText = isObscuredText ?? false,
        super(key: key);

  const RMTextFormField.basic({Key? key, required controller, padding}) : this._(key: key, padding: padding, controller: controller);

  RMTextFormField.email({Key? key, required controller, padding})
      : this._(
            key: key,
            padding: padding,
            validator: validator.MultiValidator([
              validator.RequiredValidator(errorText: 'email is required'),
              validator.EmailValidator(errorText: 'enter a valid email address'),
            ]),
            decoration: kEmailTextFieldInputDecoration,
            controller: controller);

  RMTextFormField.password({Key? key, password, required controller, padding})
      : this._(
            key: key,
            padding: padding,
            validator: validator.MultiValidator([
              validator.RequiredValidator(errorText: 'password is required'),
              validator.MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
            ]),
            decoration: kPasswordTextFieldInputDecoration,
            controller: controller,
            isObscuredText: true);

  RMTextFormField.confirmPassword({Key? key, password, required controller, padding, required TextEditingController valueToCompareController})
      : this._(
            key: key,
            padding: padding,
            validator: validator.MultiValidator([
              validator.RequiredValidator(errorText: 'Confirmation password is required'),
              validator.MinLengthValidator(8, errorText: 'Confirmation password must be at least 8 digits long'),
              MatchValidator(errorText: 'Confirmation password should be the same', valueToCompareController: valueToCompareController),
            ]),
            decoration: kPasswordAgainTextFieldInputDecoration,
            controller: controller,
            isObscuredText: true);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: TextFormField(
        controller: controller,
        validator: _validator,
        decoration: _decoration,
        obscureText: _isObscuredText,
      ),
    );
  }
}
