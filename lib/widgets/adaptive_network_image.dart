import 'package:flutter/material.dart';

class AdaptiveNetworkImage extends StatelessWidget {
  const AdaptiveNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
    this.backgroundColor,
  });

  final String? imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final radius = borderRadius ?? BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        color: backgroundColor ?? const Color(0xFF1F2937),
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: fit,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(placeholderIcon, color: Colors.white70),
                  );
                },
              )
            : Center(child: Icon(placeholderIcon, color: Colors.white70)),
      ),
    );
  }
}
