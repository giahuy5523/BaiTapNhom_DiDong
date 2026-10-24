import 'package:flutter/material.dart';

/// Ảnh mạng có vòng tải và ảnh thay thế khi URL hỏng (T07).
class PhoneImage extends StatelessWidget {
  const PhoneImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : SizedBox(
              width: width,
              height: height,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      errorBuilder: (context, error, stack) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.phone_android, color: Colors.grey, size: 40),
      ),
    );
  }
}
