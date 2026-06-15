import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last;
        return Image.memory(
          base64Decode(base64String),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      } catch (e) {
        return errorBuilder?.call(context, e, null) ?? const SizedBox.shrink();
      }
    } else if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
      );
    } else if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    } else if (url.isNotEmpty) {
      try {
        return Image.file(
          File(url),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      } catch (e) {
        return errorBuilder?.call(context, e, null) ?? const SizedBox.shrink();
      }
    } else {
      return errorBuilder?.call(context, Exception('Empty URL'), null) ?? const SizedBox.shrink();
    }
  }
}

ImageProvider getAppImageProvider(String url) {
  if (url.startsWith('data:image')) {
    try {
      final base64String = url.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } catch (_) {}
  } else if (url.startsWith('http') || url.startsWith('https')) {
    return NetworkImage(url);
  } else if (url.startsWith('assets/')) {
    return AssetImage(url);
  } else if (url.isNotEmpty) {
    return FileImage(File(url));
  }
  return const NetworkImage('https://via.placeholder.com/150');
}
