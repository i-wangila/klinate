import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../utils/responsive_utils.dart';
import 'topup_screen.dart';
import 'withdraw_screen.dart';
import 'bill_payment_screen.dart';
import 'manage_cards_screen.dart';
import 'manage_accounts_screen.dart';
import 'transaction_history_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoading = true;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    await WalletService.initialize();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _balanceVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _balanceVisible = !_balanceVisible;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cards',
                child: Row(
                  children: [
                    Icon(Icons.credit_card),
                    SizedBox(width: 8),
                    Text('Manage Cards'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'accounts',
                child: Row(
                  children: [
                    Icon(Icons.account_balance),
                    SizedBox(width: 8),
                    Text('Bank Accounts'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('Full History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshWallet,
              child: ListView(
                padding: ResponsiveUtils.getResponsivePadding(context),
                children: [
                  _buildWalletBalance(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 24),
                  ),
                  _buildQuickActions(),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 24),
                  ),
                  _buildTransactionHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildWalletBalance() {
    final wallet = WalletService.currentWallet;
    if (wallet == null) return const SizedBox.shrink();

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.grey[600],
                size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Text(
            _balanceVisible
                ? WalletService.formatCurrency(wallet.balance)
                : 'KES ****.**',
            style: TextStyle(
              color: Colors.black,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
          Text(
            'Last updated: ${DateFormat('MMM dd, HH:mm').format(wallet.lastUpdated)}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        ResponsiveUtils.isSmallScreen(context)
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Top Up',
                          Icons.add,
                          Colors.grey[700]!,
                          () => _showTopUpDialog(),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          12,
                        ),
                      ),
                      Expanded(
                        child: _buildActionCard(
                          'Withdraw',
                          Icons.remove,
                          Colors.grey[700]!,
                          () => _showWithdrawDialog(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Pay Bills',
                          Icons.receipt,
                          Colors.grey[700]!,
                          () => _showBillPaymentDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'Top Up',
                      Icons.add,
                      Colors.grey[700]!,
                      () => _showTopUpDialog(),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),
                  Expanded(
                    child: _buildActionCard(
                      'Withdraw',
                      Icons.remove,
                      Colors.grey[700]!,
                      () => _showWithdrawDialog(),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),
                  Expanded(
                    child: _buildActionCard(
                      'Pay Bills',
                      Icons.receipt,
                      Colors.grey[700]!,
                      () => _showBillPaymentDialog(),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 12),
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            ResponsiveUtils.safeText(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    final transactions = WalletService.allTransactions.take(5).toList();

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (transactions.length >= 5)
                TextButton(
                  onPressed: () => _showFullHistory(),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          if (transactions.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...transactions.map(
              (transaction) => _buildTransactionItem(transaction),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    final isCredit =
        transaction.type == TransactionType.topup ||
        transaction.type == TransactionType.refund;
    final amountColor = isCredit ? Colors.green : Colors.red;
    final amountPrefix = isCredit ? '+' : '-';

    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 8),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              WalletService.getTransactionIcon(transaction.type),
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveUtils.safeText(
                  transaction.description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
                if (transaction.reference != null)
                  ResponsiveUtils.safeText(
                    transaction.reference!,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        12,
                      ),
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                  ),
                Row(
                  children: [
                    Text(
                      WalletService.getPaymentMethodIcon(
                        transaction.paymentMethod,
                      ),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          12,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(context, 4),
                    ),
                    Text(
                      transaction.paymentMethod.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          10,
                        ),
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${WalletService.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              Text(
                DateFormat('MMM dd').format(transaction.createdAt),
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    transaction.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 8),
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  Future<void> _refreshWallet() async {
    await WalletService.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'cards':
        _showManageCardsDialog();
        break;
      case 'accounts':
        _showManageAccountsDialog();
        break;
      case 'history':
        _showFullHistory();
        break;
    }
  }

  void _showTopUpDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopUpScreen(
          onTransactionComplete: () {
            _refreshWallet();
          },
        ),
      ),
    );
  }

  void _showWithdrawDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WithdrawScreen(
          onTransactionComplete: () {
            _refreshWallet();
          },
        ),
      ),
    );
  }

  void _showBillPaymentDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillPaymentScreen(
          onTransactionComplete: () {
            _refreshWallet();
          },
        ),
      ),
    );
  }

  void _showManageCardsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageCardsScreen()),
    );
  }

  void _showManageAccountsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageAccountsScreen()),
    );
  }

  void _showFullHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransactionHistoryScreen()),
    );
  }
}
