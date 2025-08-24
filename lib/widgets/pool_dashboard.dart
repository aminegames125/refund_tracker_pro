import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/app_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import '../models/tracking_models.dart';

class PoolDashboard extends StatefulWidget {
  const PoolDashboard({super.key});

  @override
  State<PoolDashboard> createState() => _PoolDashboardState();
}

class _PoolDashboardState extends State<PoolDashboard> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final poolData = provider.poolData;

    if (poolData == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ThemeColors.getModeGradient(TrackingMode.pool),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, provider),

            // Dashboard Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: ThemeColors.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: _buildDashboardContent(context, poolData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Row(
        children: [
          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: AppConstants.iconSizeMedium,
                ),
                SizedBox(width: 8),
                Text(
                  'Pool',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.primaryFont,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Add buttons
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => _showAddExpenseDialog(context),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: AppConstants.iconSizeLarge,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => _showAddRefundDialog(context),
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: AppConstants.iconSizeLarge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, PoolTracker poolData) {
    final totalOwed = poolData.totalOwed;
    final totalRefunded = poolData.totalRefunded;
    final totalRemaining = poolData.totalRemaining;
    final progressPercentage = poolData.progressPercentage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Header
          _buildSummaryHeader(context, totalOwed, totalRefunded, totalRemaining,
              progressPercentage),
          const SizedBox(height: AppConstants.paddingLarge),

          // Recent Transactions
          if (poolData.expenses.isNotEmpty || poolData.refunds.isNotEmpty)
            _buildTransactionsSection(poolData)
          else
            _buildEmptyState(context),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, double totalOwed,
      double totalRefunded, double totalRemaining, double progressPercentage) {
    final provider = Provider.of<AppProvider>(context);
    final validationStatus = provider.getPoolValidationStatus();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: ThemeColors.cardBackground,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
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
          // Validation Warning/Error Banner
          if (validationStatus['error'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: ThemeColors.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
                border: Border.all(
                    color: ThemeColors.errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: ThemeColors.errorColor,
                    size: AppConstants.iconSizeMedium,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      validationStatus['error'],
                      style: const TextStyle(
                        fontSize: AppConstants.textSizeSmall,
                        color: ThemeColors.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (validationStatus['warning'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: ThemeColors.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
                border: Border.all(
                    color: ThemeColors.warningColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: ThemeColors.warningColor,
                    size: AppConstants.iconSizeMedium,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      validationStatus['warning'],
                      style: const TextStyle(
                        fontSize: AppConstants.textSizeSmall,
                        color: ThemeColors.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Circular Progress
          CircularPercentIndicator(
            radius: 60,
            lineWidth: 10,
            percent: progressPercentage / 100,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.getProgressColor(progressPercentage),
                  ),
                ),
                const Text(
                  'Complete',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeSmall,
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
            progressColor: ThemeColors.getProgressColor(progressPercentage),
            backgroundColor: ThemeColors.progressBackground,
            circularStrokeCap: CircularStrokeCap.round,
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Max Refundable Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: ThemeColors.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
              border: Border.all(
                  color: ThemeColors.successColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: ThemeColors.successColor,
                  size: AppConstants.iconSizeMedium,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    'Maximum refundable: ${validationStatus['maxRefundable'].toStringAsFixed(2)} TND',
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeMedium,
                      color: ThemeColors.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Owed',
                  'TND ${totalOwed.toStringAsFixed(2)}',
                  ThemeColors.errorColor,
                  Icons.money_off_rounded,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'Refunded',
                  'TND ${totalRefunded.toStringAsFixed(2)}',
                  ThemeColors.successColor,
                  Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: _buildStatCard(
                  'Remaining',
                  'TND ${totalRemaining.toStringAsFixed(2)}',
                  ThemeColors.warningColor,
                  Icons.pending_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(PoolTracker poolData) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.cardBackground,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: ThemeColors.textSecondary,
                  size: AppConstants.iconSizeMedium,
                ),
                SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: AppConstants.textSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildTransactionsList(poolData),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: ThemeColors.textTertiary,
          ),
          SizedBox(height: AppConstants.paddingLarge),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: AppConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textSecondary,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Tap + or - to add your first transaction',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppConstants.iconSizeMedium,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppConstants.textSizeSmall,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Removed unused _buildActionButton method

  Widget _buildTransactionsList(PoolTracker poolData) {
    final allTransactions = <Map<String, dynamic>>[];

    // Add expenses
    for (final expense in poolData.expenses) {
      allTransactions.add({
        'type': 'expense',
        'amount': expense.amount,
        'description': expense.description,
        'date': expense.date,
      });
    }

    // Add refunds
    for (final refund in poolData.refunds) {
      allTransactions.add({
        'type': 'refund',
        'amount': refund.amount,
        'description': refund.description,
        'date': refund.date,
      });
    }

    // Sort by date (newest first)
    allTransactions.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // Take only recent transactions
    final recentTransactions = allTransactions.take(5).toList();

    return Column(
      children: recentTransactions.map((transaction) {
        final isExpense = transaction['type'] == 'expense';
        final amount = transaction['amount'] as double;
        final description = transaction['description'] as String;
        final date = transaction['date'] as DateTime;

        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: isExpense
                ? ThemeColors.errorColor.withValues(alpha: 0.05)
                : ThemeColors.successColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
            border: Border.all(
              color: isExpense
                  ? ThemeColors.errorColor.withValues(alpha: 0.2)
                  : ThemeColors.successColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: isExpense
                      ? ThemeColors.errorColor.withValues(alpha: 0.1)
                      : ThemeColors.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThemeColors.radiusSmall),
                ),
                child: Icon(
                  isExpense ? Icons.remove_rounded : Icons.add_rounded,
                  color: isExpense
                      ? ThemeColors.errorColor
                      : ThemeColors.successColor,
                  size: AppConstants.iconSizeSmall,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: AppConstants.textSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        fontSize: AppConstants.textSizeSmall,
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isExpense ? '-' : '+'}TND ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: AppConstants.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: isExpense
                      ? ThemeColors.errorColor
                      : ThemeColors.successColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'TND ',
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              final description = descriptionController.text.trim();

              if (amount != null && amount > 0 && description.isNotEmpty) {
                final provider =
                    Provider.of<AppProvider>(context, listen: false);
                provider.addPoolExpense(amount, description).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Expense added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                }).catchError((error) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddRefundDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final maxRefundable = provider.getMaxPoolRefundable();

    // Set initial value to max refundable
    amountController.text =
        maxRefundable > 0 ? maxRefundable.toStringAsFixed(2) : '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double currentAmount = double.tryParse(amountController.text) ?? 0.0;
          bool isValid = currentAmount > 0 && currentAmount <= maxRefundable;

          return AlertDialog(
            title: const Text('Add Refund'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Max refundable info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: ThemeColors.successColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusMedium),
                    border: Border.all(
                        color: ThemeColors.successColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: ThemeColors.successColor,
                        size: AppConstants.iconSizeMedium,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Expanded(
                        child: Text(
                          'Max refundable: ${maxRefundable.toStringAsFixed(2)} TND',
                          style: const TextStyle(
                            fontSize: AppConstants.textSizeMedium,
                            color: ThemeColors.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                // Amount field
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'TND ',
                    helperText:
                        'Enter amount up to ${maxRefundable.toStringAsFixed(2)} TND',
                    errorText: currentAmount > maxRefundable
                        ? 'Amount exceeds maximum refundable'
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      currentAmount = double.tryParse(value) ?? 0.0;
                      isValid =
                          currentAmount > 0 && currentAmount <= maxRefundable;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                // Slider
                if (maxRefundable > 0) ...[
                  Text(
                    'Amount: ${currentAmount.toStringAsFixed(2)} TND',
                    style: TextStyle(
                      fontSize: AppConstants.textSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: isValid
                          ? ThemeColors.textPrimary
                          : ThemeColors.errorColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Slider(
                    value: currentAmount.clamp(0.0, maxRefundable.toDouble()),
                    min: 0.0,
                    max: maxRefundable.toDouble(),
                    divisions: (maxRefundable * 10).round(),
                    label: '${currentAmount.toStringAsFixed(2)} TND',
                    onChanged: (value) {
                      setState(() {
                        currentAmount = value;
                        amountController.text = value.toStringAsFixed(2);
                        isValid =
                            currentAmount > 0 && currentAmount <= maxRefundable;
                      });
                    },
                  ),
                ],

                const SizedBox(height: AppConstants.paddingMedium),

                // Description field
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isValid &&
                        descriptionController.text.trim().isNotEmpty
                    ? () {
                        final amount = double.tryParse(amountController.text);
                        final description = descriptionController.text.trim();

                        if (amount != null &&
                            amount > 0 &&
                            description.isNotEmpty) {
                          provider.addPoolRefund(amount, description).then((_) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Refund added successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            });
                          }).catchError((error) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $error'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          });
                        }
                      }
                    : null,
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
