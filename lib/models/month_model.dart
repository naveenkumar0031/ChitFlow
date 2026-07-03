class MonthModel {
  final int monthNumber;
  final String? auctionDate;
  final String? auctionTime;
  final double? chitValue;
  final double? bidAmount;
  final double? prizeAmount;
  final String? winnerName;
  final double? dividend;
  final String? pdfUrl;
  final DateTime? updatedAt;

  MonthModel({
    required this.monthNumber,
    this.auctionDate,
    this.auctionTime,
    this.chitValue,
    this.bidAmount,
    this.prizeAmount,
    this.winnerName,
    this.dividend,
    this.pdfUrl,
    this.updatedAt,
  });

  // A month is considered "completed/unlocked" once it has auction data.
  bool get isFilled => auctionDate != null && auctionDate!.isNotEmpty;

  factory MonthModel.empty(int monthNumber) => MonthModel(monthNumber: monthNumber);

  factory MonthModel.fromMap(int monthNumber, Map<String, dynamic>? map) {
    if (map == null) return MonthModel.empty(monthNumber);
    return MonthModel(
      monthNumber: monthNumber,
      auctionDate: map['auctionDate'],
      auctionTime: map['auctionTime'],
      chitValue: map['chitValue'] != null ? (map['chitValue']).toDouble() : null,
      bidAmount: map['bidAmount'] != null ? (map['bidAmount']).toDouble() : null,
      prizeAmount: map['prizeAmount'] != null ? (map['prizeAmount']).toDouble() : null,
      winnerName: map['winnerName'],
      dividend: map['dividend'] != null ? (map['dividend']).toDouble() : null,
      pdfUrl: map['pdfUrl'],
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'auctionDate': auctionDate,
      'auctionTime': auctionTime,
      'chitValue': chitValue,
      'bidAmount': bidAmount,
      'prizeAmount': prizeAmount,
      'winnerName': winnerName,
      'dividend': dividend,
      'pdfUrl': pdfUrl,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
