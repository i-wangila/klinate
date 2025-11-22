import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../services/mpesa_service.dart';
import '../utils/responsive_utils.dart';

class WithdrawScreen extends StatefulWidget {
  final VoidCallback onTransactionComplete;

  const WithdrawScreen({super.key, required this.onTransactionComplete});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.mpesa;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
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
            _buildAmountInput(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildWithdrawMethods(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            _buildWithdrawButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalance() {
    final wallet = WalletService.currentWallet;
    if (wallet == null) return const SizedBox.shrink();
    final balance = wallet.balance;

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: Colors.grey[700]),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Colors.grey[600],
                ),
              ),
              Text(
                WalletService.formatCurrency(balance),
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Withdrawal Amount',
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter an amount';
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < 50) return 'Minimum withdrawal amount is KES 50';

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

  Widget _buildWithdrawMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Withdraw To',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
        _buildMethodTile(
          PaymentMethod.mpesa,
          'M-Pesa',
          'Withdraw to M-Pesa account',
          Icons.phone_android,
          Colors.green,
        ),
        _buildMethodTile(
          PaymentMethod.bankTransfer,
          'Bank Account',
          'Withdraw to bank account',
          Icons.account_balance,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildMethodTile(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 8),
        ),
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(context, 8),
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        16,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        14,
                      ),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.isSmallScreen(context) ? 44 : 48,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processWithdrawal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Text(
                'Withdraw Funds',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _processWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    // Show M-Pesa phone number dialog if M-Pesa is selected
    if (_selectedMethod == PaymentMethod.mpesa) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _MpesaWithdrawalDialog(amount: amount),
      );

      if (result == true && mounted) {
        widget.onTransactionComplete();
        Navigator.pop(context);
      }
      return;
    }

    // For bank transfer, process directly
    setState(() => _isProcessing = true);

    try {
      final transaction = await WalletService.createTransaction(
        type: TransactionType.withdrawal,
        paymentMethod: _selectedMethod,
        amount: amount,
        description: 'Wallet Withdrawal',
        reference: 'Bank Withdrawal',
      );

      final success = await WalletService.processTransaction(transaction.id);

      if (success && mounted) {
        widget.onTransactionComplete();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Withdrawal successful! KES ${amount.toStringAsFixed(2)} will be sent to your bank account.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal failed. Please try again.'),
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

// M-Pesa Withdrawal Dialog
class _MpesaWithdrawalDialog extends StatefulWidget {
  final double amount;

  const _MpesaWithdrawalDialog({required this.amount});

  @override
  State<_MpesaWithdrawalDialog> createState() => _MpesaWithdrawalDialogState();
}

class _MpesaWithdrawalDialogState extends State<_MpesaWithdrawalDialog> {
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('M-Pesa Withdrawal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amount: KES ${widget.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'M-Pesa Phone Number',
              hintText: '254712345678',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Funds will be sent to this M-Pesa number.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processMpesaWithdrawal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Withdraw'),
        ),
      ],
    );
  }

  Future<void> _processMpesaWithdrawal() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    // Validate Kenyan phone number
    if (!MpesaService.isValidKenyanPhone(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Kenyan phone number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Call real M-Pesa B2C API for withdrawal
      final result = await MpesaService.initiateWithdrawal(
        phoneNumber: phoneNumber,
        amount: widget.amount,
      );

      if (result['success']) {
        // Create transaction record
        await WalletService.createTransaction(
          type: TransactionType.withdrawal,
          paymentMethod: PaymentMethod.mpesa,
          amount: widget.amount,
          description: 'M-Pesa Withdrawal',
          reference: result['conversationId'] ?? 'M-Pesa: $phoneNumber',
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Withdrawal initiated! KES ${widget.amount.toStringAsFixed(2)} will be sent to $phoneNumber.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Withdrawal failed'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
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
