import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../utils/responsive_utils.dart';

class TransferScreen extends StatefulWidget {
  final VoidCallback onTransactionComplete;

  const TransferScreen({super.key, required this.onTransactionComplete});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          children: [
            _buildCurrentBalance(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildRecipientInput(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            _buildAmountInput(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            _buildNoteInput(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            _buildTransferButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalance() {
    final wallet = WalletService.currentWallet;
    if (wallet == null) return const SizedBox.shrink();

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: Colors.blue[600]),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Colors.blue[700],
                ),
              ),
              Text(
                WalletService.formatCurrency(wallet.balance),
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextFormField(
          controller: _recipientController,
          decoration: InputDecoration(
            hintText: 'Phone number or email',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter recipient details';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: 'KES ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter an amount';
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < 10) return 'Minimum transfer amount is KES 10';

            final wallet = WalletService.currentWallet;
            if (wallet != null && amount > wallet.balance) {
              return 'Insufficient balance';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a note for this transfer',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferButton() {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.isSmallScreen(context) ? 48 : 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Send Money',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _processTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);

      final transaction = await WalletService.createTransaction(
        type: TransactionType.transfer,
        paymentMethod: PaymentMethod.wallet,
        amount: amount,
        description: 'Money Transfer',
        reference: _noteController.text.isNotEmpty
            ? _noteController.text
            : 'Transfer to ${_recipientController.text}',
        recipientId: _recipientController.text,
        recipientName: _recipientController.text,
      );

      final success = await WalletService.processTransaction(transaction.id);

      if (success && mounted) {
        widget.onTransactionComplete();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transfer successful! KES ${amount.toStringAsFixed(2)} sent to ${_recipientController.text}.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
