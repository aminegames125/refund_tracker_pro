import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import '../models/tracking_models.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);
      final title = _titleController.text.trim();
      final notes = _notesController.text.trim();

      final item = ExpenseItem(
        title: title,
        owed: amount,
        date: DateTime.now(),
        notes: notes,
      );

      await provider.addPerItemExpense(item);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final mode = provider.settings.trackingMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Item',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: ThemeColors.getModeAccent(mode),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(ThemeColors.radiusLarge),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeColors.getModeAccent(mode).withValues(alpha: 0.05),
              ThemeColors.backgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: ThemeColors.cardBackground,
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusLarge),
                    boxShadow: ThemeColors.getShadow(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: ThemeColors.getModeAccent(mode)
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(ThemeColors.radiusMedium),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            color: ThemeColors.getModeAccent(mode),
                            size: AppConstants.iconSizeLarge,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'New Expense Item',
                                style: TextStyle(
                                  fontSize: AppConstants.textSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add a new item to track refunds',
                                style: TextStyle(
                                  fontSize: AppConstants.textSizeMedium,
                                  color: ThemeColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Title Field Card
                Container(
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: ThemeColors.cardBackground,
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusLarge),
                    boxShadow: ThemeColors.getShadow(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  AppConstants.paddingSmall),
                              decoration: BoxDecoration(
                                color: ThemeColors.infoColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    ThemeColors.radiusMedium),
                              ),
                              child: const Icon(
                                Icons.title_rounded,
                                color: ThemeColors.infoColor,
                                size: AppConstants.iconSizeMedium,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            const Text(
                              'Item Title',
                              style: TextStyle(
                                fontSize: AppConstants.textSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Enter item title',
                            hintText: 'e.g., MacBook Pro, iPhone 15',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeColors.radiusMedium),
                            ),
                            prefixIcon: const Icon(
                              Icons.inventory_2_rounded,
                              color: ThemeColors.textTertiary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            if (value.trim().length < 3) {
                              return 'Title must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Amount Field Card
                Container(
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: ThemeColors.cardBackground,
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusLarge),
                    boxShadow: ThemeColors.getShadow(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  AppConstants.paddingSmall),
                              decoration: BoxDecoration(
                                color: ThemeColors.errorColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    ThemeColors.radiusMedium),
                              ),
                              child: const Icon(
                                Icons.attach_money_rounded,
                                color: ThemeColors.errorColor,
                                size: AppConstants.iconSizeMedium,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: AppConstants.textSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter amount',
                            hintText: '0.00',
                            prefixText: 'TND ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeColors.radiusMedium),
                            ),
                            prefixIcon: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: ThemeColors.textTertiary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Amount is required';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            if (amount > 999999.99) {
                              return 'Amount cannot exceed 999,999.99';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Notes Field Card
                Container(
                  margin:
                      const EdgeInsets.only(bottom: AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: ThemeColors.cardBackground,
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusLarge),
                    boxShadow: ThemeColors.getShadow(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  AppConstants.paddingSmall),
                              decoration: BoxDecoration(
                                color: ThemeColors.warningColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    ThemeColors.radiusMedium),
                              ),
                              child: const Icon(
                                Icons.note_rounded,
                                color: ThemeColors.warningColor,
                                size: AppConstants.iconSizeMedium,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            const Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: AppConstants.textSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Additional notes (optional)',
                            hintText:
                                'Add any additional details about this item...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeColors.radiusMedium),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 32),
                              child: Icon(
                                Icons.description_rounded,
                                color: ThemeColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusLarge),
                    boxShadow: ThemeColors.getShadow(),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.getModeAccent(mode),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingLarge,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeColors.radiusLarge),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: AppConstants.iconSizeMedium,
                              ),
                              SizedBox(width: AppConstants.paddingSmall),
                              Text(
                                'Add Item',
                                style: TextStyle(
                                  fontSize: AppConstants.textSizeLarge,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
