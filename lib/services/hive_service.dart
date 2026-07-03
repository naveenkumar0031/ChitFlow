import 'package:hive_flutter/hive_flutter.dart';

/// Simple Hive wrapper used only on the Admin device to cache the
/// member list for fast selection while creating a chit.
class HiveService {
  static const String memberBoxName = 'memberBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(memberBoxName);
  }

  Box get _memberBox => Hive.box(memberBoxName);

  /// Save a member as { name, phone } under key = phone
  Future<void> cacheMember({required String name, required String phone}) async {
    await _memberBox.put(phone, {'name': name, 'phone': phone});
  }

  /// Returns a list of maps: [{name, phone}, ...]
  List<Map<String, dynamic>> getCachedMembers() {
    return _memberBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearCache() async {
    await _memberBox.clear();
  }
}
