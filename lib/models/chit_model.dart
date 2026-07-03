class ChitMember {
  final String phone;
  final String name;

  ChitMember({required this.phone, required this.name});

  factory ChitMember.fromMap(String phone, Map<String, dynamic> map) {
    return ChitMember(phone: phone, name: map['name'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}

class ChitModel {
  final String chitId;
  final String chitName;
  final double totalAmount;
  final int totalMembers;
  final int totalMonths;
  final List<ChitMember> members;
  final DateTime createdDate;

  ChitModel({
    required this.chitId,
    required this.chitName,
    required this.totalAmount,
    required this.totalMembers,
    required this.totalMonths,
    required this.members,
    required this.createdDate,
  });

  factory ChitModel.fromMap(String id, Map<String, dynamic> map) {
    final membersMap = (map['members'] as Map<String, dynamic>?) ?? {};
    final membersList = membersMap.entries
        .map((e) => ChitMember.fromMap(e.key, e.value as Map<String, dynamic>))
        .toList();

    return ChitModel(
      chitId: id,
      chitName: map['chitName'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      totalMembers: map['totalMembers'] ?? 0,
      totalMonths: map['totalMonths'] ?? 0,
      members: membersList,
      createdDate: map['createdDate'] != null
          ? DateTime.tryParse(map['createdDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final membersMap = <String, dynamic>{};
    for (final m in members) {
      membersMap[m.phone] = m.toMap();
    }
    return {
      'chitName': chitName,
      'totalAmount': totalAmount,
      'totalMembers': totalMembers,
      'totalMonths': totalMonths,
      'members': membersMap,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  bool containsMember(String phone) => members.any((m) => m.phone == phone);
}
