class BookModel {
  final int id;
  final String name;
  final String description;
  final String bid;
  final String createdAt;
  final int transactionsCount;
  final double balance;

  BookModel({
    required this.id,
    required this.name,
    required this.description,
    required this.bid,
    required this.createdAt,
    required this.transactionsCount,
    required this.balance,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      bid: json['bid'] ?? '',
      createdAt: json['created_at'],
      transactionsCount: json['transactions_count'] ?? 0,
      balance: (json['balance'] ?? 0.0).toDouble(),
    );
  }
}
