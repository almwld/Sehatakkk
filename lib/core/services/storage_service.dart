import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadImage(File image, String folder) async {
    final ref = _storage.ref().child('$folder/${_uuid.v4()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<String> uploadFile(File file, String folder) async {
    final ref = _storage.ref().child('$folder/${_uuid.v4()}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  }
}
