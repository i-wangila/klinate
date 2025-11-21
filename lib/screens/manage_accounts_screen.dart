import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
import '../utils/responsive_utils.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'M-Pesa'),
            Tab(text: 'Bank Accounts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMpesaTab(), _buildBankTab()],
      ),
    );
  }

  Widget _buildMpesaTab() {
    final accounts = WalletService.mpesaAccounts;

    return accounts.isEmpty
        ? _buildEmptyState('M-Pesa', Icons.phone_android, _showAddMpesaDialog)
        : ListView.builder(
            padding: ResponsiveUtils.getResponsivePadding(context),
            itemCount: accounts.length + 1,
            itemBuilder: (context, index) {
              if (index == accounts.length) {
                return _buildAddButton(
                  'Add M-Pesa Account',
                  _showAddMpesaDialog,
                );
              }
              return _buildMpesaItem(accounts[index]);
            },
          );
  }

  Widget _buildBankTab() {
    final accounts = WalletService.bankAccounts;

    return accounts.isEmpty
        ? _buildEmptyState(
            'Bank Account',
            Icons.account_balance,
            _showAddBankDialog,
          )
        : ListView.builder(
            padding: ResponsiveUtils.getResponsivePadding(context),
            itemCount: accounts.length + 1,
            itemBuilder: (context, index) {
              if (index == accounts.length) {
                return _buildAddButton('Add Bank Account', _showAddBankDialog);
              }
              return _buildBankItem(accounts[index]);
            },
          );
  }

  Widget _buildEmptyState(String type, IconData icon, VoidCallback onAdd) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Text(
            'No $type added yet',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text('Add $type'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          padding: ResponsiveUtils.getResponsivePadding(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMpesaItem(account) {
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
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.phone_android, color: Colors.green[600]),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.phoneNumber,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  account.name,
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
              if (value == 'delete') _removeMpesaAccount(account.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBankItem(account) {
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
            child: Icon(Icons.account_balance, color: Colors.blue[600]),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.bankName,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  account.accountNumber,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  account.accountName,
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
              if (value == 'delete') _removeBankAccount(account.id);
            },
          ),
        ],
      ),
    );
  }

  void _showAddMpesaDialog() {
    final phoneController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add M-Pesa Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (phoneController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                await WalletService.addMpesaAccount(
                  phoneNumber: phoneController.text,
                  name: nameController.text,
                );
                if (mounted) {
                  setState(() {});
                }
                navigator.pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddBankDialog() {
    final bankController = TextEditingController();
    final accountController = TextEditingController();
    final nameController = TextEditingController();
    final branchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bank Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: branchController,
                decoration: const InputDecoration(
                  labelText: 'Branch Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if ([
                bankController,
                accountController,
                nameController,
                branchController,
              ].every((c) => c.text.isNotEmpty)) {
                final navigator = Navigator.of(context);
                await WalletService.addBankAccount(
                  bankName: bankController.text,
                  accountNumber: accountController.text,
                  accountName: nameController.text,
                  branchCode: branchController.text,
                );
                if (mounted) {
                  setState(() {});
                }
                navigator.pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeMpesaAccount(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove M-Pesa Account'),
        content: const Text(
          'Are you sure you want to remove this M-Pesa account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await WalletService.removeMpesaAccount(id);
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

  void _removeBankAccount(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bank Account'),
        content: const Text(
          'Are you sure you want to remove this bank account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await WalletService.removeBankAccount(id);
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
