enum TransactionType {
  topup,
  withdrawal,
  transfer,
  payment,
  billPayment,
  refund,
}

enum TransactionStatus { pending, completed, failed, cancelled }

enum PaymentMethod { mpesa, bankTransfer, creditCard, debitCard, wallet }

class WalletTransaction {
  final String id;
  final String userId;
  final TransactionType type;
  final PaymentMethod paymentMethod;
  final double amount;
  final String currency;
  final String description;
  final String? reference;
  final String? recipientId;
  final String? recipientName;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.paymentMethod,
    required this.amount,
    this.currency = 'KES',
    required this.description,
    this.reference,
    this.recipientId,
    this.recipientName,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'paymentMethod': paymentMethod.name,
      'amount': amount,
      'currency': currency,
      'description': description,
      'reference': reference,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      userId: json['userId'],
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
      ),
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'KES',
      description: json['description'],
      reference: json['reference'],
      recipientId: json['recipientId'],
      recipientName: json['recipientName'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      metadata: json['metadata'],
    );
  }

  WalletTransaction copyWith({
    TransactionStatus? status,
    DateTime? completedAt,
    String? reference,
    Map<String, dynamic>? metadata,
  }) {
    return WalletTransaction(
      id: id,
      userId: userId,
      type: type,
      paymentMethod: paymentMethod,
      amount: amount,
      currency: currency,
      description: description,
      reference: reference ?? this.reference,
      recipientId: recipientId,
      recipientName: recipientName,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PaymentCard {
  final String id;
  final String userId;
  final String cardNumber; // Masked
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cardType; // Visa, Mastercard, etc.
  final bool isDefault;
  final DateTime createdAt;

  PaymentCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardType,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cardType': cardType,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'],
      userId: json['userId'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      cardType: json['cardType'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class BankAccount {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber; // Masked
  final String accountName;
  final String branchCode;
  final bool isDefault;
  final DateTime createdAt;

  BankAccount({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.branchCode,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'branchCode': branchCode,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      userId: json['userId'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      branchCode: json['branchCode'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MpesaAccount {
  final String id;
  final String userId;
  final String phoneNumber;
  final String name;
  final bool isDefault;
  final DateTime createdAt;

  MpesaAccount({
    required this.id,
    required this.userId,
    required this.phoneNumber,
    required this.name,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'name': name,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MpesaAccount.fromJson(Map<String, dynamic> json) {
    return MpesaAccount(
      id: json['id'],
      userId: json['userId'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Wallet {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final DateTime lastUpdated;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'KES',
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      balance: json['balance'].toDouble(),
      currency: json['currency'] ?? 'KES',
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Wallet copyWith({double? balance, DateTime? lastUpdated}) {
    return Wallet(
      id: id,
      userId: userId,
      balance: balance ?? this.balance,
      currency: currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
