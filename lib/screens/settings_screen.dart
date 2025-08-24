import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/app_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import '../models/tracking_models.dart';
import '../services/app_info_service.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final mode = provider.settings.trackingMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
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
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          children: [
            _buildSectionHeader('Tracking Mode'),
            _buildModeSelectionCard(context, provider, mode),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSectionHeader('Notifications'),
            _buildNotificationCard(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSectionHeader('Data Management'),
            _buildDataManagementCard(context, provider),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSectionHeader('App Information'),
            _buildAppInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.paddingSmall,
        bottom: AppConstants.paddingMedium,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppConstants.textSizeLarge,
          fontWeight: FontWeight.bold,
          color: ThemeColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildModeSelectionCard(
      BuildContext context, AppProvider provider, TrackingMode currentMode) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.cardBackground,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: ThemeColors.getShadow(),
      ),
      child: Column(
        children: [
          _buildModeOption(
            context: context,
            provider: provider,
            mode: TrackingMode.perItem,
            title: 'Per-Item Tracking',
            subtitle: 'Track each expense item individually',
            icon: Icons.inventory_2_rounded,
            color: ThemeColors.perItemAccent,
            isSelected: currentMode == TrackingMode.perItem,
          ),
          _buildDivider(),
          _buildModeOption(
            context: context,
            provider: provider,
            mode: TrackingMode.pool,
            title: 'Pool Tracking',
            subtitle: 'Track all expenses in a single pool',
            icon: Icons.account_balance_wallet_rounded,
            color: ThemeColors.poolAccent,
            isSelected: currentMode == TrackingMode.pool,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.cardBackground,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: ThemeColors.getShadow(),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.notifications_active_rounded,
            title: 'CashFlow Comedian',
            subtitle: 'AI-powered funny notifications',
            color: ThemeColors.primaryColor,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required AppProvider provider,
    required TrackingMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _showModeChangeDialog(context, provider, mode),
      borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeSmall,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: ThemeColors.dividerColor,
      indent: AppConstants.paddingLarge,
      endIndent: AppConstants.paddingLarge,
    );
  }

  Widget _buildDataManagementCard(BuildContext context, AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.cardBackground,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: ThemeColors.getShadow(),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.file_download_rounded,
            title: 'Export Data',
            subtitle: 'Export your data as CSV or PDF',
            color: ThemeColors.infoColor,
            onTap: () => _showExportDialog(context),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.delete_forever_rounded,
            title: 'Clear All Data',
            subtitle: 'Permanently delete all data',
            color: ThemeColors.errorColor,
            onTap: () => _showClearDataDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: AppConstants.textSizeSmall,
                      color: ThemeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: ThemeColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(BuildContext context) {
    final appInfo = AppInfoService();

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.cardBackground,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: ThemeColors.getShadow(),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.info_rounded,
            title: 'Version',
            value: appInfo.fullVersion,
            color: ThemeColors.infoColor,
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.code_rounded,
            title: 'Build Number',
            value: appInfo.buildNumber,
            color: ThemeColors.warningColor,
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.fingerprint_rounded,
            title: 'Build Signature',
            value: appInfo.buildSignature,
            color: ThemeColors.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.textSizeMedium,
                fontWeight: FontWeight.w600,
                color: ThemeColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showModeChangeDialog(
      BuildContext context, AppProvider provider, TrackingMode newMode) {
    final currentMode = provider.settings.trackingMode;
    if (currentMode == newMode) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        ),
        title: const Text('Switch Tracking Mode?'),
        content: const Text(
          'Switching modes will clear all existing data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await provider.switchMode(newMode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Switch Mode'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        ),
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose export format:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _exportData(context, provider, 'csv');
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _exportData(context, provider, 'json');
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('JSON'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.infoColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportData(
      BuildContext context, AppProvider provider, String format) async {
    try {
      final data = _generateExportData(provider);
      String content;
      String filename;

      if (format == 'csv') {
        content = _generateCSV(data);
        filename =
            'refund_tracker_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      } else {
        content = _generateJSON(data);
        filename =
            'refund_tracker_export_${DateTime.now().millisecondsSinceEpoch}.json';
      }

      // For now, just show the data in a dialog
      // In a real app, you would save this to a file
      _showExportResult(context, content, filename);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: ThemeColors.errorColor,
        ),
      );
    }
  }

  Map<String, dynamic> _generateExportData(AppProvider provider) {
    final mode = provider.settings.trackingMode;
    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'tracking_mode': mode.toString(),
      'currency': provider.settings.currency,
      'total_owed': provider.totalOwed,
      'total_refunded': provider.totalRefunded,
      'total_remaining': provider.totalRemaining,
      'progress_percentage': provider.progressPercentage,
    };

    switch (mode) {
      case TrackingMode.perItem:
        data['items'] = provider.perItemData
            .map((item) => {
                  'id': item.id,
                  'title': item.title,
                  'owed': item.owed,
                  'refunded': item.refunded,
                  'remaining': item.remaining,
                  'progress_percentage': item.progressPercentage,
                  'date': item.date.toIso8601String(),
                  'notes': item.notes,
                  'refunds': item.refunds
                      .map((refund) => {
                            'amount': refund.amount,
                            'date': refund.date.toIso8601String(),
                            'notes': refund.notes,
                          })
                      .toList(),
                })
            .toList();
        break;
      case TrackingMode.pool:
        if (provider.poolData != null) {
          data['expenses'] = provider.poolData!.expenses
              .map((expense) => {
                    'amount': expense.amount,
                    'date': expense.date.toIso8601String(),
                    'description': expense.description,
                  })
              .toList();
          data['refunds'] = provider.poolData!.refunds
              .map((refund) => {
                    'amount': refund.amount,
                    'date': refund.date.toIso8601String(),
                    'description': refund.description,
                  })
              .toList();
        }
        break;
      case TrackingMode.hybrid:
        if (provider.hybridData != null) {
          data['items'] = provider.hybridData!.items
              .map((item) => {
                    'id': item.id,
                    'title': item.title,
                    'owed': item.owed,
                    'refunded': item.refunded,
                    'remaining': item.remaining,
                    'progress_percentage': item.progressPercentage,
                    'date': item.date.toIso8601String(),
                    'notes': item.notes,
                    'refunds': item.refunds
                        .map((refund) => {
                              'amount': refund.amount,
                              'date': refund.date.toIso8601String(),
                              'notes': refund.notes,
                            })
                        .toList(),
                  })
              .toList();
          data['standalone_expenses'] =
              provider.hybridData!.standalonePool.expenses
                  .map((expense) => {
                        'amount': expense.amount,
                        'date': expense.date.toIso8601String(),
                        'description': expense.description,
                      })
                  .toList();
          data['standalone_refunds'] =
              provider.hybridData!.standalonePool.refunds
                  .map((refund) => {
                        'amount': refund.amount,
                        'date': refund.date.toIso8601String(),
                        'description': refund.description,
                      })
                  .toList();
        }
        break;
    }

    return data;
  }

  String _generateCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Export Date,${data['export_date']}');
    buffer.writeln('Tracking Mode,${data['tracking_mode']}');
    buffer.writeln('Currency,${data['currency']}');
    buffer.writeln('Total Owed,${data['total_owed']}');
    buffer.writeln('Total Refunded,${data['total_refunded']}');
    buffer.writeln('Total Remaining,${data['total_remaining']}');
    buffer.writeln('Progress Percentage,${data['progress_percentage']}');
    buffer.writeln();

    // Items data
    if (data.containsKey('items')) {
      buffer.writeln('Items:');
      buffer.writeln('ID,Title,Owed,Refunded,Remaining,Progress %,Date,Notes');
      for (final item in data['items']) {
        buffer.writeln(
            '${item['id']},"${item['title']}",${item['owed']},${item['refunded']},${item['remaining']},${item['progress_percentage']},${item['date']},"${item['notes']}"');
      }
      buffer.writeln();
    }

    // Pool data
    if (data.containsKey('expenses')) {
      buffer.writeln('Pool Expenses:');
      buffer.writeln('Amount,Date,Description');
      for (final expense in data['expenses']) {
        buffer.writeln(
            '${expense['amount']},${expense['date']},"${expense['description']}"');
      }
      buffer.writeln();
    }

    if (data.containsKey('refunds')) {
      buffer.writeln('Pool Refunds:');
      buffer.writeln('Amount,Date,Description');
      for (final refund in data['refunds']) {
        buffer.writeln(
            '${refund['amount']},${refund['date']},"${refund['description']}"');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _generateJSON(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _showExportResult(
      BuildContext context, String content, String filename) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        ),
        title: Text('Export: $filename'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        ),
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}
