import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/tracking_models.dart';
import '../providers/app_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import '../screens/item_detail_screen.dart';

class PerItemDashboard extends StatelessWidget {
  const PerItemDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ThemeColors.getModeGradient(TrackingMode.perItem),
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
                  child: _buildDashboardContent(context, provider),
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
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: AppConstants.iconSizeMedium,
                ),
                SizedBox(width: 8),
                Text(
                  'Per-Item',
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

          // Add button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pushNamed('/add-item'),
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: AppConstants.iconSizeLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Header
          _buildSummaryHeader(context, provider),
          const SizedBox(height: AppConstants.paddingLarge),

          // Items List
          _buildItemsList(context, provider),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, AppProvider provider) {
    final totalOwed = provider.totalOwed;
    final totalRefunded = provider.totalRefunded;
    final totalRemaining = provider.totalRemaining;
    final progressPercentage = provider.progressPercentage;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    'Total Owed',
                    style: TextStyle(
                      fontSize: AppConstants.textSizeSmall,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TND ${totalOwed.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.errorColor,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Total Refunded',
                    style: TextStyle(
                      fontSize: AppConstants.textSizeSmall,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TND ${totalRefunded.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.successColor,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: AppConstants.textSizeSmall,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TND ${totalRemaining.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.warningColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          LinearProgressIndicator(
            value: (progressPercentage / 100)
                .clamp(0.0, 1.0), // Fix: clamp to 0.0-1.0
            backgroundColor: ThemeColors.progressBackground,
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeColors.getProgressColor(progressPercentage),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            '${progressPercentage.toStringAsFixed(1)}% Refunded',
            style: const TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, AppProvider provider) {
    if (provider.perItemData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items List (${provider.perItemData.length} items)',
          style: const TextStyle(
            fontSize: AppConstants.textSizeLarge,
            fontWeight: FontWeight.bold,
            color: ThemeColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.perItemData.length,
          itemBuilder: (context, index) {
            final item = provider.perItemData[index];
            return _buildItemCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: ThemeColors.textTertiary,
          ),
          SizedBox(height: AppConstants.paddingLarge),
          Text(
            'No items yet',
            style: TextStyle(
              fontSize: AppConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textSecondary,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Tap + to add your first item',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ExpenseItem item) {
    final remaining = item.remaining;
    final progressPercentage = item.progressPercentage;

    return InkWell(
      onTap: () => _showItemDetail(context, item),
      borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: ThemeColors.cardBackground,
          borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
          boxShadow: const [
            BoxShadow(
              color: ThemeColors.shadowColorLight,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.inventory_2_rounded,
                color: ThemeColors.getModeAccent(TrackingMode.perItem),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontSize: AppConstants.textSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: ThemeColors.textTertiary,
                size: AppConstants.iconSizeSmall,
              ),
              onTap: () => _showItemDetail(context, item),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Owed: TND ${item.owed.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: AppConstants.textSizeMedium,
                    color: ThemeColors.errorColor,
                  ),
                ),
                Text(
                  'Refunded: TND ${item.refunded.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: AppConstants.textSizeMedium,
                    color: ThemeColors.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            LinearProgressIndicator(
              value: (progressPercentage / 100)
                  .clamp(0.0, 1.0), // Fix: clamp to 0.0-1.0
              backgroundColor: ThemeColors.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeColors.getProgressColor(progressPercentage),
              ),
              minHeight: 6,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              '${progressPercentage.toStringAsFixed(1)}% Complete • TND ${remaining.toStringAsFixed(2)} remaining',
              style: const TextStyle(
                fontSize: AppConstants.textSizeSmall,
                color: ThemeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context, ExpenseItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(itemId: item.id),
      ),
    );
  }
}
