import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static BorderRadius get small =>
      BorderRadius.circular(4);

  static BorderRadius get medium =>
      BorderRadius.circular(8);

  static BorderRadius get large =>
      BorderRadius.circular(14);

  static BorderRadius get pill =>
      BorderRadius.circular(999);
}