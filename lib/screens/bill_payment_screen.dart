import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import '../utils/responsive_utils.dart';

class BillPaymentScreen extends StatefulWidget {
  final VoidCallback onTransactionComplete;

  const BillPaymentScreen({super.key, required this.onTransactionComplete});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tillNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  String _selectedBillType = 'consultation';
  bool _isProcessing = false;

  final Map<String, Map<String, dynamic>> _medicalBillTypes = {
    'consultation': {
      'name': 'Consultation Fee',
      'icon': Icons.medical_services,
      'color': Colors.grey[700],
      'description': 'Pay for doctor consultation',
    },
    'pharmacy': {
      'name': 'Pharmacy Bill',
      'icon': Icons.local_pharmacy,
      'color': Colors.grey[700],
      'description': 'Pay for medications',
    },
    'laboratory': {
      'name': 'Laboratory Tests',
      'icon': Icons.science,
      'color': Colors.grey[700],
      'description': 'Pay for lab tests and diagnostics',
    },
    'hospital': {
      'name': 'Hospital Bill',
      'icon': Icons.local_hospital,
      'color': Colors.grey[700],
      'description': 'Pay hospital admission or treatment bills',
    },
    'imaging': {
      'name': 'Imaging Services',
      'icon': Icons.camera_alt,
      'color': Colors.grey[700],
      'description': 'Pay for X-ray, CT scan, MRI, etc.',
    },
  };

  @override
  void dispose() {
    _tillNumberController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pay Medical Bills',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 20),
          ),
          children: [
            _buildCurrentBalance(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            Text(
              'Select Service Type',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            _buildBillTypeSelection(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            _buildTillNumberInput(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            _buildAmountInput(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            _buildReferenceInput(),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalance() {
    final wallet = WalletService.currentWallet;
    if (wallet == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.grey[700],
              size: 28,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'KSh ${wallet.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTypeSelection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _medicalBillTypes.length,
      itemBuilder: (context, index) {
        final type = _medicalBillTypes.keys.elementAt(index);
        final billType = _medicalBillTypes[type]!;
        final isSelected = _selectedBillType == type;

        return GestureDetector(
          onTap: () => setState(() => _selectedBillType = type),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  billType['icon'],
                  color: isSelected ? Colors.black : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  billType['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTillNumberInput() {
    return TextFormField(
      controller: _tillNumberController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      ),
      decoration: InputDecoration(
        labelText: 'Till Number / Paybill',
        hintText: 'Enter provider till number',
        prefixIcon: Icon(Icons.numbers, color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter till number';
        }
        return null;
      },
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      ),
      decoration: InputDecoration(
        labelText: 'Amount (KSh)',
        hintText: 'Enter amount to pay',
        prefixIcon: Icon(Icons.attach_money, color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        final wallet = WalletService.currentWallet;
        if (wallet != null && amount > wallet.balance) {
          return 'Insufficient balance';
        }
        return null;
      },
    );
  }

  Widget _buildReferenceInput() {
    return TextFormField(
      controller: _referenceController,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      ),
      decoration: InputDecoration(
        labelText: 'Reference (Optional)',
        hintText: 'e.g., Invoice number, Patient ID',
        prefixIcon: Icon(Icons.receipt_long, color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processBillPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey[300]!),
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Pay Bill',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _processBillPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);
      final billTypeName = _medicalBillTypes[_selectedBillType]!['name'];

      final transaction = await WalletService.createTransaction(
        type: TransactionType.billPayment,
        paymentMethod: PaymentMethod.wallet,
        amount: amount,
        description: '$billTypeName - Till: ${_tillNumberController.text}',
        reference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
      );

      await WalletService.processTransaction(transaction.id);

      if (mounted) {
        widget.onTransactionComplete();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bill payment of KSh ${amount.toStringAsFixed(2)} successful',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
