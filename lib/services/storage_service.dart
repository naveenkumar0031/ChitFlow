import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a PDF file for a given chit + month and returns the download URL.
  Future<String> uploadAuctionPdf({
    required String chitId,
    required int monthNumber,
    required File file,
  }) async {
    final ref = _storage.ref().child('auctionSheets/$chitId/month_$monthNumber.pdf');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
