import 'package:flutter/material.dart';

abstract class UniqueEvent {
  @override
  int get hashCode => UniqueKey().hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}