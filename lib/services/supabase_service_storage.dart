import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseServiceStorage {
     // ======================= STORAGE ============================

  static Future<String?> uploadImage({
    required XFile image,
    required String bucketName,
    required String fileName,
  }) async {
    try {
      final bytes = await image.readAsBytes();

      await supabase.storage
          .from(bucketName)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from(bucketName).getPublicUrl(fileName);
    } catch (e) {
      print("❌ uploadImage error: $e");
      return null;
    }
  }
}