import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet.dart';

class WalletService {
  static const String _walletKey = 'wallet_data';
  static const String _transactionsKey = 'wallet_transactions';
  static const String _cardsKey = 'payment_cards';
  static const String _bankAccountsKey = 'bank_accounts';
  static const String _mpesaAccountsKey = 'mpesa_accounts';

  static Wallet? _currentWallet;
  static List<WalletTransaction> _transactions = [];
  static List<PaymentCard> _paymentCards = [];
  static List<BankAccount> _bankAccounts = [];
  static List<MpesaAccount> _mpesaAccounts = [];

  // Initialize wallet service
  static Future<void> initialize() async {
    await _loadWallet();
    await _loadTransactions();
    await _loadPaymentMethods();
  }

  // Wallet operations
  static Wallet? get currentWallet => _currentWallet;

  static Future<void> _loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final walletData = prefs.getString(_walletKey);

    if (walletData != null) {
      _currentWallet = Wallet.fromJson(jsonDecode(walletData));
    } else {
      // Create default wallet
      _currentWallet = Wallet(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user', // Replace with actual user ID
        balance: 2500.0, // Default balance
        lastUpdated: DateTime.now(),
      );
      await _saveWallet();
    }
  }

  static Future<void> _saveWallet() async {
    if (_currentWallet != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_walletKey, jsonEncode(_currentWallet!.toJson()));
    }
  }

  static Future<void> updateBalance(double newBalance) async {
    if (_currentWallet != null) {
      _currentWallet = _currentWallet!.copyWith(
        balance: newBalance,
        lastUpdated: DateTime.now(),
      );
      await _saveWallet();
    }
  }

  // Transaction operations
  static List<WalletTransaction> get allTransactions =>
      List.from(_transactions);

  static Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsData = prefs.getString(_transactionsKey);

    if (transactionsData != null) {
      final List<dynamic> jsonList = jsonDecode(transactionsData);
      _transactions = jsonList
          .map((json) => WalletTransaction.fromJson(json))
          .toList();
    } else {
      // Add some sample transactions
      _transactions = [
        WalletTransaction(
          id: 'txn_1',
          userId: 'current_user',
          type: TransactionType.payment,
          paymentMethod: PaymentMethod.wallet,
          amount: 1500.0,
          description: 'Consultation Payment',
          reference: 'Dr. Smith - Video Call',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        WalletTransaction(
          id: 'txn_2',
          userId: 'current_user',
          type: TransactionType.topup,
          paymentMethod: PaymentMethod.mpesa,
          amount: 5000.0,
          description: 'Wallet Top-up',
          reference: 'M-Pesa Payment',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        WalletTransaction(
          id: 'txn_3',
          userId: 'current_user',
          type: TransactionType.payment,
          paymentMethod: PaymentMethod.wallet,
          amount: 850.0,
          description: 'Prescription Payment',
          reference: 'Goodlife Pharmacy',
          status: TransactionStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      await _saveTransactions();
    }
  }

  static Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _transactions
        .map((transaction) => transaction.toJson())
        .toList();
    await prefs.setString(_transactionsKey, jsonEncode(jsonList));
  }

  static Future<WalletTransaction> createTransaction({
    required TransactionType type,
    required PaymentMethod paymentMethod,
    required double amount,
    required String description,
    String? reference,
    String? recipientId,
    String? recipientName,
    Map<String, dynamic>? metadata,
  }) async {
    final transaction = WalletTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      userId: 'current_user',
      type: type,
      paymentMethod: paymentMethod,
      amount: amount,
      description: description,
      reference: reference,
      recipientId: recipientId,
      recipientName: recipientName,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _transactions.insert(0, transaction);
    await _saveTransactions();
    return transaction;
  }

  static Future<bool> processTransaction(String transactionId) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) return false;

    final transaction = _transactions[index];

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate success/failure (90% success rate)
    final isSuccess = Random().nextDouble() > 0.1;

    if (isSuccess) {
      // Update wallet balance based on transaction type
      if (_currentWallet != null) {
        double newBalance = _currentWallet!.balance;

        switch (transaction.type) {
          case TransactionType.topup:
            newBalance += transaction.amount;
            break;
          case TransactionType.withdrawal:
          case TransactionType.payment:
          case TransactionType.transfer:
          case TransactionType.billPayment:
            newBalance -= transaction.amount;
            break;
          case TransactionType.refund:
            newBalance += transaction.amount;
            break;
        }

        await updateBalance(newBalance);
      }

      // Update transaction status
      _transactions[index] = transaction.copyWith(
        status: TransactionStatus.completed,
        completedAt: DateTime.now(),
      );
    } else {
      _transactions[index] = transaction.copyWith(
        status: TransactionStatus.failed,
      );
    }

    await _saveTransactions();
    return isSuccess;
  }

  // Payment methods operations
  static List<PaymentCard> get paymentCards => List.from(_paymentCards);
  static List<BankAccount> get bankAccounts => List.from(_bankAccounts);
  static List<MpesaAccount> get mpesaAccounts => List.from(_mpesaAccounts);

  static Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();

    // Load payment cards
    final cardsData = prefs.getString(_cardsKey);
    if (cardsData != null) {
      final List<dynamic> jsonList = jsonDecode(cardsData);
      _paymentCards = jsonList
          .map((json) => PaymentCard.fromJson(json))
          .toList();
    }

    // Load bank accounts
    final bankData = prefs.getString(_bankAccountsKey);
    if (bankData != null) {
      final List<dynamic> jsonList = jsonDecode(bankData);
      _bankAccounts = jsonList
          .map((json) => BankAccount.fromJson(json))
          .toList();
    }

    // Load M-Pesa accounts
    final mpesaData = prefs.getString(_mpesaAccountsKey);
    if (mpesaData != null) {
      final List<dynamic> jsonList = jsonDecode(mpesaData);
      _mpesaAccounts = jsonList
          .map((json) => MpesaAccount.fromJson(json))
          .toList();
    }
  }

  static Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();

    // Save payment cards
    final cardsJson = _paymentCards.map((card) => card.toJson()).toList();
    await prefs.setString(_cardsKey, jsonEncode(cardsJson));

    // Save bank accounts
    final bankJson = _bankAccounts.map((account) => account.toJson()).toList();
    await prefs.setString(_bankAccountsKey, jsonEncode(bankJson));

    // Save M-Pesa accounts
    final mpesaJson = _mpesaAccounts
        .map((account) => account.toJson())
        .toList();
    await prefs.setString(_mpesaAccountsKey, jsonEncode(mpesaJson));
  }

  // Add payment methods
  static Future<PaymentCard> addPaymentCard({
    required String cardNumber,
    required String cardHolderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    // Mask card number (show only last 4 digits)
    final maskedNumber =
        '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';

    // Determine card type
    String cardType = 'Unknown';
    if (cardNumber.startsWith('4')) {
      cardType = 'Visa';
    } else if (cardNumber.startsWith('5')) {
      cardType = 'Mastercard';
    } else if (cardNumber.startsWith('3')) {
      cardType = 'American Express';
    }

    final card = PaymentCard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      cardNumber: maskedNumber,
      cardHolderName: cardHolderName,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cardType: cardType,
      isDefault: _paymentCards.isEmpty,
      createdAt: DateTime.now(),
    );

    _paymentCards.add(card);
    await _savePaymentMethods();
    return card;
  }

  static Future<BankAccount> addBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String branchCode,
  }) async {
    // Mask account number (show only last 4 digits)
    final maskedNumber =
        '****${accountNumber.substring(accountNumber.length - 4)}';

    final account = BankAccount(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      bankName: bankName,
      accountNumber: maskedNumber,
      accountName: accountName,
      branchCode: branchCode,
      isDefault: _bankAccounts.isEmpty,
      createdAt: DateTime.now(),
    );

    _bankAccounts.add(account);
    await _savePaymentMethods();
    return account;
  }

  static Future<MpesaAccount> addMpesaAccount({
    required String phoneNumber,
    required String name,
  }) async {
    final account = MpesaAccount(
      id: 'mpesa_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      phoneNumber: phoneNumber,
      name: name,
      isDefault: _mpesaAccounts.isEmpty,
      createdAt: DateTime.now(),
    );

    _mpesaAccounts.add(account);
    await _savePaymentMethods();
    return account;
  }

  // Remove payment methods
  static Future<void> removePaymentCard(String cardId) async {
    _paymentCards.removeWhere((card) => card.id == cardId);
    await _savePaymentMethods();
  }

  static Future<void> removeBankAccount(String accountId) async {
    _bankAccounts.removeWhere((account) => account.id == accountId);
    await _savePaymentMethods();
  }

  static Future<void> removeMpesaAccount(String accountId) async {
    _mpesaAccounts.removeWhere((account) => account.id == accountId);
    await _savePaymentMethods();
  }

  // Utility methods
  static String formatCurrency(double amount, {String currency = 'KES'}) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  static String getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.topup:
        return '💰';
      case TransactionType.withdrawal:
        return '💸';
      case TransactionType.transfer:
        return '🔄';
      case TransactionType.payment:
        return '💳';
      case TransactionType.billPayment:
        return '🧾';
      case TransactionType.refund:
        return '↩️';
    }
  }

  static String getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mpesa:
        return '📱';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return '💳';
      case PaymentMethod.wallet:
        return '👛';
    }
  }
}
