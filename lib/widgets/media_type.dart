enum MediaType { text, image, video, other }

MediaType detectMediaType(String? url) {
  if (url == null || url.isEmpty) return MediaType.text;

  final u = url.toLowerCase();

  // 🎥 VIDÉOS (très large)
  if (u.endsWith('.mp4') ||
      u.endsWith('.mov') ||
      u.endsWith('.webm') ||
      u.endsWith('.mkv') ||
      u.endsWith('.avi') ||
      u.endsWith('.flv') ||
      u.endsWith('.wmv') ||
      u.endsWith('.m4v') ||
      u.endsWith('.3gp')) {
    return MediaType.video;
  }

  // 🖼️ IMAGES
  if (u.endsWith('.jpg') ||
      u.endsWith('.jpeg') ||
      u.endsWith('.png') ||
      u.endsWith('.webp') ||
      u.endsWith('.gif') ||
      u.endsWith('.bmp') ||
      u.endsWith('.heic')) {
    return MediaType.image;
  }

  return MediaType.other;
}
