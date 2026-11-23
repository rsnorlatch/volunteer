import 'dart:io';

import 'package:flutter/material.dart';

Widget profilePhotoImage(String path, {required Widget fallback}) => Image.file(
      File(path),
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
