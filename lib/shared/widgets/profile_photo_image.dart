import 'package:flutter/material.dart';

import 'profile_photo_image_io.dart'
    if (dart.library.js_interop) 'profile_photo_image_web.dart' as image;

Widget profilePhotoImage(String path, {required Widget fallback}) =>
    image.profilePhotoImage(path, fallback: fallback);
