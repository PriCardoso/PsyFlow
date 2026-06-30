import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance =
      StorageService._();

  final FirebaseStorage storage =
      FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {

    final ref = storage.ref(path);

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(
    String path,
  ) async {

    await storage.ref(path).delete();
  }
}