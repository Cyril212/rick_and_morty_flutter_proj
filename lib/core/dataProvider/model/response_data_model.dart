import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';

import 'data_model.dart';
import 'data_model.dart';

abstract class ResponseDataModel extends DataModel {
  ResponseDataModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {};
}
