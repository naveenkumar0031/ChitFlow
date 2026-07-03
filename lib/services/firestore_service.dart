import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/chit_model.dart';
import '../models/month_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- USERS ----------------

  CollectionReference get _users => _db.collection('users');

  Future<AppUser?> getUser(String phone) async {
    final doc = await _users.doc(phone).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> createMember({
    required String name,
    required String phone,
    required String password,
  }) async {
    final user = AppUser(name: name, phone: phone, password: password, role: 'member');
    await _users.doc(phone).set(user.toMap());
  }

  Future<List<AppUser>> getAllMembers() async {
    final snapshot = await _users.where('role', isEqualTo: 'member').get();
    return snapshot.docs
        .map((d) => AppUser.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  // ---------------- CHITS ----------------

  CollectionReference get _chits => _db.collection('chits');

  Future<String> createChit(ChitModel chit) async {
    final docRef = await _chits.add(chit.toMap());
    return docRef.id;
  }

  Future<List<ChitModel>> getAllChits() async {
    final snapshot = await _chits.orderBy('createdDate', descending: true).get();
    return snapshot.docs
        .map((d) => ChitModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChitModel>> getChitsForMember(String phone) async {
    final all = await getAllChits();
    return all.where((c) => c.containsMember(phone)).toList();
  }

  Future<ChitModel?> getChit(String chitId) async {
    final doc = await _chits.doc(chitId).get();
    if (!doc.exists) return null;
    return ChitModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // ---------------- MONTHS / AUCTIONS ----------------

  CollectionReference _monthsCollection(String chitId) =>
      _chits.doc(chitId).collection('months');

  Future<MonthModel> getMonth(String chitId, int monthNumber) async {
    final doc = await _monthsCollection(chitId).doc('month_$monthNumber').get();
    if (!doc.exists) return MonthModel.empty(monthNumber);
    return MonthModel.fromMap(monthNumber, doc.data() as Map<String, dynamic>);
  }

  Future<List<MonthModel>> getAllMonths(String chitId, int totalMonths) async {
    final snapshot = await _monthsCollection(chitId).get();
    final Map<int, MonthModel> filled = {};
    for (final doc in snapshot.docs) {
      final num = int.tryParse(doc.id.replaceAll('month_', '')) ?? 0;
      filled[num] = MonthModel.fromMap(num, doc.data() as Map<String, dynamic>);
    }
    return List.generate(totalMonths, (i) {
      final monthNumber = i + 1;
      return filled[monthNumber] ?? MonthModel.empty(monthNumber);
    });
  }

  Future<void> updateAuction(String chitId, int monthNumber, MonthModel month) async {
    await _monthsCollection(chitId).doc('month_$monthNumber').set(month.toMap());
  }
}
