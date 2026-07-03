import 'dart:io';
import 'package:flutter/material.dart';
import '../models/chit_model.dart';
import '../models/month_model.dart';
import '../services/firestore_service.dart';
import '../services/hive_service.dart';
import '../services/storage_service.dart';

class ChitProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final HiveService _hiveService = HiveService();
  final StorageService _storageService = StorageService();

  List<ChitModel> _chits = [];
  bool _isLoading = false;

  List<ChitModel> get chits => _chits;
  bool get isLoading => _isLoading;

  // ---------------- MEMBERS ----------------

  Future<void> createMember({
    required String name,
    required String phone,
    required String password,
  }) async {
    await _firestoreService.createMember(name: name, phone: phone, password: password);
    // Cache in Hive for fast admin-side selection
    await _hiveService.cacheMember(name: name, phone: phone);
  }

  List<Map<String, dynamic>> getCachedMembers() {
    return _hiveService.getCachedMembers();
  }

  /// Refresh Hive cache from Firestore (useful first run / after reinstall).
  Future<void> syncMembersToHive() async {
    final members = await _firestoreService.getAllMembers();
    for (final m in members) {
      await _hiveService.cacheMember(name: m.name, phone: m.phone);
    }
  }

  // ---------------- CHITS ----------------

  Future<void> loadAllChits() async {
    _isLoading = true;
    notifyListeners();
    _chits = await _firestoreService.getAllChits();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadChitsForMember(String phone) async {
    _isLoading = true;
    notifyListeners();
    _chits = await _firestoreService.getChitsForMember(phone);
    _isLoading = false;
    notifyListeners();
  }

  Future<String> createChit({
    required String chitName,
    required double totalAmount,
    required int totalMembers,
    required int totalMonths,
    required List<ChitMember> selectedMembers,
  }) async {
    final chit = ChitModel(
      chitId: '',
      chitName: chitName,
      totalAmount: totalAmount,
      totalMembers: totalMembers,
      totalMonths: totalMonths,
      members: selectedMembers,
      createdDate: DateTime.now(),
    );
    final id = await _firestoreService.createChit(chit);
    return id;
  }

  // ---------------- MONTHS / AUCTIONS ----------------

  Future<List<MonthModel>> getMonths(String chitId, int totalMonths) {
    return _firestoreService.getAllMonths(chitId, totalMonths);
  }

  Future<void> updateAuction({
    required String chitId,
    required int monthNumber,
    required MonthModel monthData,
    File? pdfFile,
  }) async {
    String? pdfUrl = monthData.pdfUrl;
    if (pdfFile != null) {
      pdfUrl = await _storageService.uploadAuctionPdf(
        chitId: chitId,
        monthNumber: monthNumber,
        file: pdfFile,
      );
    }

    final updatedMonth = MonthModel(
      monthNumber: monthNumber,
      auctionDate: monthData.auctionDate,
      auctionTime: monthData.auctionTime,
      chitValue: monthData.chitValue,
      bidAmount: monthData.bidAmount,
      prizeAmount: monthData.prizeAmount,
      winnerName: monthData.winnerName,
      dividend: monthData.dividend,
      pdfUrl: pdfUrl,
    );

    await _firestoreService.updateAuction(chitId, monthNumber, updatedMonth);
  }
}
