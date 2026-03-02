class TransactionModel {
  final int id;
  final double amount;
  final String type;
  final String note;
  final String createdAt;
  final double signAmount;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.note,
    required this.createdAt,
    required this.signAmount,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: json['type'],
      note: json['note'] ?? '',
      createdAt: json['created_at'],
      signAmount: (json['sign_amount'] ?? 0.0).toDouble(),
    );
  }
}
