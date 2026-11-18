import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Picks a listing photo (camera or gallery) and copies it into the app's
/// documents directory so the listing keeps working even if the original
/// gallery image is deleted. Returns the stored file path, or null when
/// the user cancels.
class PhotoService {
  PhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickAndStorePhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'listing_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final stored = await File(
      picked.path,
    ).copy(p.join(photosDir.path, fileName));
    return stored.path;
  }

  /// Best-effort delete of a stored photo file.
  Future<void> deletePhoto(String? photoPath) async {
    if (photoPath == null) return;
    try {
      final file = File(photoPath);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A stale photo file must never block deleting the listing itself.
    }
  }
}
