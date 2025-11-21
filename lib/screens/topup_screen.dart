import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../utils/responsive_utils.dart';

class TopUpScreen extends StatefulWidget {
  final VoidCallback onTransactionComplete;

  const TopUpScreen({super.key, required this.onTransactionComplete});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.mpesa;
  bool _isProcessing = false;

  final List<double> _quickAmounts = [100, 500, 1000, 2000, 5000, 10000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
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
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            _buildQuickAmounts(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildPaymentMethods(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            _buildTopUpButton(),
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
                'Current Balance',
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

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Amount',
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
            prefixStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount < 10) {
              return 'Minimum top-up amount is KES 10';
            }
            if (amount > 100000) {
              return 'Maximum top-up amount is KES 100,000';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildQuickAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amounts',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
        Wrap(
          spacing: ResponsiveUtils.getResponsiveSpacing(context, 8),
          runSpacing: ResponsiveUtils.getResponsiveSpacing(context, 8),
          children: _quickAmounts.map((amount) {
            return GestureDetector(
              onTap: () {
                _amountController.text = amount.toStringAsFixed(0);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'KES ${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
        _buildPaymentMethodTile(
          PaymentMethod.mpesa,
          'M-Pesa',
          'Pay with M-Pesa mobile money',
          Icons.phone_android,
          Colors.green,
        ),
        _buildPaymentMethodTile(
          PaymentMethod.bankTransfer,
          'Bank Transfer',
          'Transfer from your bank account',
          Icons.account_balance,
          Colors.blue,
        ),
        _buildPaymentMethodTile(
          PaymentMethod.creditCard,
          'Credit/Debit Card',
          'Pay with Visa, Mastercard, etc.',
          Icons.credit_card,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
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
              child: Icon(
                icon,
                color: color,
                size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
              ),
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
                        14,
                      ),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: ResponsiveUtils.isSmallScreen(context) ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpButton() {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.isSmallScreen(context) ? 44 : 48,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processTopUp,
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
                'Top Up Wallet',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _processTopUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      // Create transaction
      final transaction = await WalletService.createTransaction(
        type: TransactionType.topup,
        paymentMethod: _selectedMethod,
        amount: amount,
        description: 'Wallet Top-up',
        reference: _getPaymentReference(),
      );

      // Show payment dialog based on method
      bool paymentSuccess = false;

      switch (_selectedMethod) {
        case PaymentMethod.mpesa:
          paymentSuccess = await _showMpesaPayment(amount);
          break;
        case PaymentMethod.bankTransfer:
          paymentSuccess = await _showBankTransferPayment(amount);
          break;
        case PaymentMethod.creditCard:
          paymentSuccess = await _showCardPayment(amount);
          break;
        default:
          paymentSuccess = false;
      }

      if (paymentSuccess) {
        // Process the transaction
        final success = await WalletService.processTransaction(transaction.id);

        if (success && mounted) {
          widget.onTransactionComplete();
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Top-up successful! KES ${amount.toStringAsFixed(2)} added to your wallet.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _getPaymentReference() {
    switch (_selectedMethod) {
      case PaymentMethod.mpesa:
        return 'M-Pesa Payment';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.creditCard:
        return 'Card Payment';
      default:
        return 'Payment';
    }
  }

  Future<bool> _showMpesaPayment(double amount) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => MpesaPaymentDialog(amount: amount),
        ) ??
        false;
  }

  Future<bool> _showBankTransferPayment(double amount) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => BankTransferDialog(amount: amount),
        ) ??
        false;
  }

  Future<bool> _showCardPayment(double amount) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => CardPaymentDialog(amount: amount),
        ) ??
        false;
  }
}

// M-Pesa Payment Dialog
class MpesaPaymentDialog extends StatefulWidget {
  final double amount;

  const MpesaPaymentDialog({super.key, required this.amount});

  @override
  State<MpesaPaymentDialog> createState() => _MpesaPaymentDialogState();
}

class _MpesaPaymentDialogState extends State<MpesaPaymentDialog> {
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('M-Pesa Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
            'You will receive an M-Pesa prompt on your phone to complete the payment.',
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
          onPressed: _isProcessing ? null : _processMpesaPayment,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Pay'),
        ),
      ],
    );
  }

  Future<void> _processMpesaPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate M-Pesa processing
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}

// Bank Transfer Dialog
class BankTransferDialog extends StatelessWidget {
  final double amount;

  const BankTransferDialog({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bank Transfer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amount: KES ${amount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          const Text(
            'Transfer to:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text('Bank: Klinate Bank'),
          const Text('Account: 1234567890'),
          const Text('Reference: Your phone number'),
          const SizedBox(height: 16),
          const Text(
            'Please complete the bank transfer and it will be processed within 24 hours.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('I\'ve Transferred'),
        ),
      ],
    );
  }
}

// Card Payment Dialog
class CardPaymentDialog extends StatefulWidget {
  final double amount;

  const CardPaymentDialog({super.key, required this.amount});

  @override
  State<CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<CardPaymentDialog> {
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Card Payment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: KES ${widget.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processCardPayment,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Pay'),
        ),
      ],
    );
  }

  Future<void> _processCardPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate card processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
