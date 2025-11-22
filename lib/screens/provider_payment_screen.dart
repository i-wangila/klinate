import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/c2b_payment_service.dart';
import '../utils/responsive_utils.dart';

class ProviderPaymentScreen extends StatefulWidget {
  final String providerId;
  final String providerName;
  final double amount;
  final String description;
  final String? appointmentId;

  const ProviderPaymentScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.amount,
    required this.description,
    this.appointmentId,
  });

  @override
  State<ProviderPaymentScreen> createState() => _ProviderPaymentScreenState();
}

class _ProviderPaymentScreenState extends State<ProviderPaymentScreen> {
  bool _isLoading = false;
  bool _paymentInitiated = false;
  Map<String, dynamic>? _paymentDetails;
  final _mpesaCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    setState(() => _isLoading = true);

    try {
      final result = await C2BPaymentService.initiateProviderPayment(
        providerId: widget.providerId,
        providerName: widget.providerName,
        amount: widget.amount,
        description: widget.description,
        appointmentId: widget.appointmentId,
      );

      setState(() {
        _paymentDetails = result;
        _paymentInitiated = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Provider'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paymentInitiated
          ? _buildPaymentInstructions()
          : const Center(child: Text('Initializing payment...')),
    );
  }

  Widget _buildPaymentInstructions() {
    final isTill = _paymentDetails?['tillNumber'] != null;
    final paybillNumber = _paymentDetails?['paybillNumber'];
    final tillNumber = _paymentDetails?['tillNumber'];
    final accountNumber = _paymentDetails?['accountNumber'];

    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Summary Card
          Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.green[700], size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay ${widget.providerName}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                18,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount to Pay:',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          16,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'KES ${widget.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

          // M-Pesa Instructions
          Text(
            'How to Pay via M-Pesa',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),

          // Payment Details Card
          Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                if (isTill) ...[
                  _buildCopyableField('Till Number', tillNumber!, Icons.store),
                ] else ...[
                  _buildCopyableField(
                    'Paybill Number',
                    paybillNumber!,
                    Icons.business,
                  ),
                  if (accountNumber != null && accountNumber.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCopyableField(
                      'Account Number',
                      accountNumber,
                      Icons.account_balance,
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                _buildCopyableField(
                  'Amount',
                  widget.amount.toStringAsFixed(2),
                  Icons.money,
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

          // Step-by-step instructions
          _buildInstructionStep(
            1,
            'Open M-Pesa on your phone',
            'Go to M-Pesa menu on your Safaricom line',
          ),
          _buildInstructionStep(
            2,
            isTill ? 'Select "Lipa na M-Pesa"' : 'Select "Lipa na M-Pesa"',
            isTill
                ? 'Then select "Buy Goods and Services"'
                : 'Then select "Pay Bill"',
          ),
          _buildInstructionStep(
            3,
            isTill
                ? 'Enter Till Number: $tillNumber'
                : 'Enter Paybill: $paybillNumber',
            isTill
                ? 'Enter the till number shown above'
                : accountNumber != null && accountNumber.isNotEmpty
                ? 'Enter Account Number: $accountNumber'
                : 'Leave account number blank or enter your phone number',
          ),
          _buildInstructionStep(
            4,
            'Enter Amount: KES ${widget.amount.toStringAsFixed(2)}',
            'Enter your M-Pesa PIN to complete',
          ),
          _buildInstructionStep(
            5,
            'You will receive an M-Pesa confirmation SMS',
            'Copy the M-Pesa code (e.g., QA12BC3DEF) and enter it below',
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

          // M-Pesa Code Input
          Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Payment',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _mpesaCodeController,
                  decoration: InputDecoration(
                    labelText: 'M-Pesa Confirmation Code',
                    hintText: 'e.g., QA12BC3DEF',
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Confirm Payment',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          16,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _cancelPayment,
              child: Text(
                'Cancel Payment',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label copied to clipboard'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInstructionStep(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
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
      ),
    );
  }

  Future<void> _confirmPayment() async {
    if (_mpesaCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the M-Pesa confirmation code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await C2BPaymentService.confirmPayment(
        paymentId: _paymentDetails!['paymentId'],
        mpesaCode: _mpesaCodeController.text.trim().toUpperCase(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment confirmed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelPayment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await C2BPaymentService.cancelPayment(_paymentDetails!['paymentId']);
        if (mounted) {
          Navigator.pop(context, false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _mpesaCodeController.dispose();
    super.dispose();
  }
}
