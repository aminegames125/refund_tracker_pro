import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import '../models/tracking_models.dart';

class AddRefundScreen extends StatefulWidget {
  final String? itemId;
  final String? itemTitle;

  const AddRefundScreen({
    super.key,
    this.itemId,
    this.itemTitle,
  });

  @override
  State<AddRefundScreen> createState() => _AddRefundScreenState();
}

class _AddRefundScreenState extends State<AddRefundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  String? _itemId;
  String? _itemTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _itemId = args['itemId'] ?? widget.itemId;
          _itemTitle = args['itemTitle'] ?? widget.itemTitle;
        });
      } else {
        setState(() {
          _itemId = widget.itemId;
          _itemTitle = widget.itemTitle;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addRefund() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      final notes = _notesController.text.trim();

      switch (provider.settings.trackingMode) {
        case TrackingMode.perItem:
          if (_itemId != null) {
            await provider.addPerItemRefund(_itemId!, amount, notes);
          }
          break;
        case TrackingMode.pool:
          await provider.addPoolRefund(amount, description);
          break;
        case TrackingMode.hybrid:
          if (_itemId != null) {
            await provider.addPerItemRefund(_itemId!, amount, notes);
          } else {
            await provider.addHybridStandaloneRefund(amount, description);
          }
          break;
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refund added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding refund: $e'),
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

    // Get current item details for validation
    ExpenseItem? currentItem;
    if (mode == TrackingMode.perItem && _itemId != null) {
      currentItem = provider.perItemData.firstWhere(
        (i) => i.id == _itemId,
        orElse: () => ExpenseItem(
          title: 'Unknown',
          owed: 0,
          date: DateTime.now(),
        ),
      );
    } else if (mode == TrackingMode.hybrid && _itemId != null) {
      currentItem = provider.hybridData?.items.firstWhere(
        (i) => i.id == _itemId,
        orElse: () => ExpenseItem(
          title: 'Unknown',
          owed: 0,
          date: DateTime.now(),
        ),
      );
    }

    String title = 'Add Refund';
    if (mode == TrackingMode.perItem && _itemTitle != null) {
      title = 'Add Refund to $_itemTitle';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
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
                // Current Item Status Card (for per-item mode)
                if (currentItem != null)
                  Container(
                    margin: const EdgeInsets.only(
                        bottom: AppConstants.paddingLarge),
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
                                  Icons.info_rounded,
                                  color: ThemeColors.infoColor,
                                  size: AppConstants.iconSizeMedium,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              const Text(
                                'Current Status',
                                style: TextStyle(
                                  fontSize: AppConstants.textSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),

                          // Status Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatusItem(
                                  'Owed',
                                  'TND ${currentItem.owed.toStringAsFixed(2)}',
                                  ThemeColors.errorColor,
                                ),
                              ),
                              Expanded(
                                child: _buildStatusItem(
                                  'Refunded',
                                  'TND ${currentItem.refunded.toStringAsFixed(2)}',
                                  ThemeColors.successColor,
                                ),
                              ),
                              Expanded(
                                child: _buildStatusItem(
                                  'Remaining',
                                  'TND ${currentItem.remaining.toStringAsFixed(2)}',
                                  ThemeColors.warningColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppConstants.paddingMedium),

                          // Progress Bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Progress',
                                    style: TextStyle(
                                      fontSize: AppConstants.textSizeMedium,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${currentItem.progressPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: AppConstants.textSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeColors.getProgressColor(
                                          currentItem.progressPercentage),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.paddingSmall),
                              LinearProgressIndicator(
                                value: currentItem.progressPercentage / 100,
                                backgroundColor: ThemeColors.progressBackground,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ThemeColors.getProgressColor(
                                      currentItem.progressPercentage),
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(
                                    ThemeColors.radiusFull),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Amount Field Card
                Container(
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
                                color: ThemeColors.successColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    ThemeColors.radiusMedium),
                              ),
                              child: const Icon(
                                Icons.attach_money_rounded,
                                color: ThemeColors.successColor,
                                size: AppConstants.iconSizeMedium,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingMedium),
                            const Text(
                              'Refund Amount',
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
                            labelText: 'Amount',
                            prefixText: 'TND ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeColors.radiusMedium),
                            ),
                            helperText: currentItem != null
                                ? 'Maximum refund: TND ${currentItem.remaining.toStringAsFixed(2)}'
                                : null,
                            helperStyle: const TextStyle(
                              color: ThemeColors.textSecondary,
                              fontSize: AppConstants.textSizeSmall,
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

                            // Check for over-refunding
                            if (currentItem != null &&
                                amount > currentItem.remaining) {
                              return 'Amount cannot exceed remaining balance (TND ${currentItem.remaining.toStringAsFixed(2)})';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                // Description Field Card (for pool and hybrid standalone)
                if (mode == TrackingMode.pool ||
                    (mode == TrackingMode.hybrid && _itemId == null))
                  Container(
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
                                  Icons.description_rounded,
                                  color: ThemeColors.infoColor,
                                  size: AppConstants.iconSizeMedium,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingMedium),
                              const Text(
                                'Description',
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
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeColors.radiusMedium),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                if (mode == TrackingMode.pool ||
                    (mode == TrackingMode.hybrid && _itemId == null))
                  const SizedBox(height: AppConstants.paddingMedium),

                // Notes Field Card
                Container(
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
                            labelText: 'Notes (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeColors.radiusMedium),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Add Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusLarge),
                    boxShadow: ThemeColors.getShadow(),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        (currentItem != null && currentItem.remaining <= 0) ||
                                _isLoading
                            ? null
                            : _addRefund,
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
                        : Text(
                            currentItem != null && currentItem.remaining <= 0
                                ? 'Fully Refunded'
                                : 'Add Refund',
                            style: const TextStyle(
                              fontSize: AppConstants.textSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.textSizeSmall,
            color: ThemeColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppConstants.textSizeMedium,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
