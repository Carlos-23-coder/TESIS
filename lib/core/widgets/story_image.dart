import 'dart:io';

import 'package:flutter/material.dart';

class StoryImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final BoxFit fit;

  const StoryImage({
    super.key,
    required this.imagePath,
    this.height = 220,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }

    final file = File(imagePath);

    if (file.existsSync()) {
      return Image.file(
        file,
        height: height,
        width: double.infinity,
        fit: fit,
      );
    }

    return const SizedBox.shrink();
  }
}
