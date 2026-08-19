import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/app_exception.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({required FirebaseStorage storage}) : _storage = storage;

  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      final ref = _storage.ref(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw AppException('Erro ao fazer upload: $e', originalError: e);
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      throw AppException('Erro ao excluir arquivo: $e', originalError: e);
    }
  }
}