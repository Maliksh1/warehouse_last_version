class Invoice {
  final String number;
  final double amount;
  final String status;

  Invoice({
    required this.number,
    required this.amount,
    required this.status,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      number: json['number'],
      amount: json['amount'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'amount': amount,
      'status': status,
    };
  }
}
