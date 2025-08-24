import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/tracking_models.dart';
import '../utils/app_constants.dart';
import '../utils/theme_colors.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final mode = provider.settings.trackingMode;

    // Find the item
    ExpenseItem? item;
    if (provider.settings.trackingMode == TrackingMode.perItem) {
      item = provider.perItemData.firstWhere(
        (i) => i.id == itemId,
        orElse: () => ExpenseItem(
          title: 'Unknown',
          owed: 0,
          date: DateTime.now(),
        ),
      );
    } else if (provider.settings.trackingMode == TrackingMode.hybrid) {
      item = provider.hybridData?.items.firstWhere(
        (i) => i.id == itemId,
        orElse: () => ExpenseItem(
          title: 'Unknown',
          owed: 0,
          date: DateTime.now(),
        ),
      );
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Item Not Found'),
          backgroundColor: ThemeColors.getModeAccent(mode),
        ),
        body: const Center(
          child: Text('Item not found'),
        ),
      );
    }

    final remaining = item.remaining;
    final progressPercentage = item.progressPercentage;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: ThemeColors.getModeAccent(mode),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, provider, item!),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ThemeColors.getModeAccent(mode).withValues(alpha: 0.1),
              ThemeColors.getModeAccent(mode).withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Header (matching dashboard design)
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: ThemeColors.surfaceColor,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusLarge),
                  boxShadow: const [
                    BoxShadow(
                      color: ThemeColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: AppConstants.textSizeXXLarge,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.textPrimary,
                        fontFamily: AppConstants.primaryFont,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Progress Bar
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: ThemeColors.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeColors.getProgressColor(progressPercentage),
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      '${progressPercentage.toStringAsFixed(1)}% Complete',
                      style: const TextStyle(
                        fontSize: AppConstants.textSizeMedium,
                        color: ThemeColors.textSecondary,
                        fontFamily: AppConstants.primaryFont,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Amount Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountItem(
                            'Owed', item.owed, ThemeColors.errorColor),
                        _buildAmountItem('Refunded', item.refunded,
                            ThemeColors.successColor),
                        _buildAmountItem(
                            'Remaining', remaining, ThemeColors.warningColor),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Refunds List
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.surfaceColor,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusLarge),
                  boxShadow: const [
                    BoxShadow(
                      color: ThemeColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      child: Text(
                        'Refund History',
                        style: TextStyle(
                          fontSize: AppConstants.textSizeXLarge,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.textPrimary,
                          fontFamily: AppConstants.primaryFont,
                        ),
                      ),
                    ),
                    if (item.refunds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppConstants.paddingLarge),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 60,
                                color: ThemeColors.textTertiary,
                              ),
                              SizedBox(height: AppConstants.paddingMedium),
                              Text(
                                'No refunds yet',
                                style: TextStyle(
                                  fontSize: AppConstants.textSizeLarge,
                                  color: ThemeColors.textSecondary,
                                  fontFamily: AppConstants.primaryFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: item.refunds.length,
                        itemBuilder: (context, index) {
                          final refund = item!.refunds[index];
                          return _buildRefundItem(context, refund);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: remaining > 0
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddRefund(context, item!),
              backgroundColor: ThemeColors.getModeAccent(mode),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Refund'),
            )
          : null,
    );
  }

  Widget _buildAmountItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.textSizeSmall,
            color: ThemeColors.textSecondary,
            fontFamily: AppConstants.primaryFont,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'TND ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: AppConstants.textSizeLarge,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: AppConstants.primaryFont,
          ),
        ),
      ],
    );
  }

  Widget _buildRefundItem(BuildContext context, RefundEvent refund) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: ThemeColors.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: ThemeColors.borderColorLight),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: ThemeColors.successColor,
            child: Icon(
              Icons.attach_money,
              color: Colors.white,
              size: AppConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TND ${refund.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: AppConstants.textSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.successColor,
                    fontFamily: AppConstants.primaryFont,
                  ),
                ),
                Text(
                  '${refund.date.day}/${refund.date.month}/${refund.date.year}',
                  style: const TextStyle(
                    fontSize: AppConstants.textSizeSmall,
                    color: ThemeColors.textSecondary,
                    fontFamily: AppConstants.primaryFont,
                  ),
                ),
                if (refund.notes.isNotEmpty)
                  Text(
                    refund.notes,
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeSmall,
                      color: ThemeColors.textSecondary,
                      fontStyle: FontStyle.italic,
                      fontFamily: AppConstants.primaryFont,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddRefund(BuildContext context, ExpenseItem item) {
    Navigator.pushNamed(
      context,
      '/add-refund',
      arguments: {
        'itemId': item.id,
        'itemTitle': item.title,
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, AppProvider provider, ExpenseItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deletePerItemExpense(item.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
