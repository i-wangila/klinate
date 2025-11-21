import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';
import '../utils/responsive_utils.dart';

class ManageCardsScreen extends StatefulWidget {
  const ManageCardsScreen({super.key});

  @override
  State<ManageCardsScreen> createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends State<ManageCardsScreen> {
  @override
  Widget build(BuildContext context) {
    final cards = WalletService.paymentCards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Cards'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCardDialog,
          ),
        ],
      ),
      body: cards.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: ResponsiveUtils.getResponsivePadding(context),
              itemCount: cards.length,
              itemBuilder: (context, index) => _buildCardItem(cards[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 80, color: Colors.grey[400]),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Text(
            'No cards added yet',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          ElevatedButton.icon(
            onPressed: _showAddCardDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(card) {
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(context, 8),
            ),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.credit_card, color: Colors.blue[600]),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.cardNumber,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  card.cardHolderName,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${card.cardType} • Expires ${card.expiryMonth}/${card.expiryYear}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') _removeCard(card.id);
            },
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCardDialog(
        onCardAdded: () {
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeCard(String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Card'),
        content: const Text('Are you sure you want to remove this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await WalletService.removePaymentCard(cardId);
              if (mounted) {
                setState(() {});
              }
              navigator.pop();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddCardDialog extends StatefulWidget {
  final VoidCallback onCardAdded;

  const AddCardDialog({super.key, required this.onCardAdded});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Payment Card'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.length != 16
                    ? 'Enter valid 16-digit card number'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Enter cardholder name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'MMYY',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.length != 4 ? 'Enter MMYY' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.length != 3 ? 'Enter 3-digit CVV' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _addCard, child: const Text('Add Card')),
      ],
    );
  }

  void _addCard() async {
    if (_formKey.currentState!.validate()) {
      final expiry = _expiryController.text;
      await WalletService.addPaymentCard(
        cardNumber: _cardController.text,
        cardHolderName: _nameController.text,
        expiryMonth: expiry.substring(0, 2),
        expiryYear: expiry.substring(2, 4),
        cvv: _cvvController.text,
      );
      widget.onCardAdded();
    }
  }
}
