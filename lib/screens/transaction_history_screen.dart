import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../utils/responsive_utils.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'all';
  final Map<String, String> _filters = {
    'all': 'All Transactions',
    'topup': 'Top-ups',
    'withdrawal': 'Withdrawals',
    'transfer': 'Transfers',
    'payment': 'Payments',
    'billPayment': 'Bill Payments',
  };

  @override
  Widget build(BuildContext context) {
    final allTransactions = WalletService.allTransactions;
    final filteredTransactions = _selectedFilter == 'all'
        ? allTransactions
        : allTransactions.where((t) => t.type.name == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => _filters.entries
                .map(
                  (e) => PopupMenuItem(
                    value: e.key,
                    child: Row(
                      children: [
                        if (_selectedFilter == e.key)
                          const Icon(Icons.check, size: 16),
                        if (_selectedFilter == e.key) const SizedBox(width: 8),
                        Text(e.value),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedFilter != 'all') _buildFilterChip(),
          Expanded(
            child: filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) =>
                        _buildTransactionItem(filteredTransactions[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Row(
        children: [
          Chip(
            label: Text(_filters[_selectedFilter]!),
            onDeleted: () => setState(() => _selectedFilter = 'all'),
            deleteIcon: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Text(
            _selectedFilter == 'all'
                ? 'No transactions yet'
                : 'No ${_filters[_selectedFilter]!.toLowerCase()} found',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              color: Colors.grey[600],
            ),
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

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 8),
                ),
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  WalletService.getTransactionIcon(transaction.type),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      16,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(context, 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveUtils.safeText(
                      transaction.description,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          16,
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
                            14,
                          ),
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                      ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 4),
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
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            4,
                          ),
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
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              transaction.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                8,
                              ),
                              color: _getStatusColor(transaction.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(context, 12),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix${WalletService.formatCurrency(transaction.amount)}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(transaction.createdAt),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        12,
                      ),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (transaction.recipientName != null) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  ),
                  Text(
                    'To: ${transaction.recipientName}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        12,
                      ),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
}
