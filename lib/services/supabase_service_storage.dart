import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceStorage {
  // ======================= STORAGE ============================

  static Future<String?> uploadFile({
    required XFile file,
    required String bucketName,
    required String fileName,
     String? contentType,
  }) async {
    try {
      final bytes = await file.readAsBytes();
   await supabase.storage.from(bucketName).uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: contentType),
      );

      return supabase.storage.from(bucketName).getPublicUrl(fileName);
    } catch (e) {
      print("❌ uploadFile error: $e");
      return null;
    }
  }
   static Future<String?> uploadImage({
    required XFile image,
    required String bucketName,
    required String fileName,
  }) async {
    return uploadFile(
      file: image,
      bucketName: bucketName,
      fileName: fileName,
      contentType: 'image/jpeg',
    );
  }
}
