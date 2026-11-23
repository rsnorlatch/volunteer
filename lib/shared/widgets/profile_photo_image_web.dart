import 'dart:convert';

import 'package:flutter/material.dart';

Widget profilePhotoImage(String path, {required Widget fallback}) {
  final separator = path.indexOf(',');
  if (separator < 0) return fallback;
  try {
    return Image.memory(
      base64Decode(path.substring(separator + 1)),
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  } on FormatException {
    return fallback;
  }
}
