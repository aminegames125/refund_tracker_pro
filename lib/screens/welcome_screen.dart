import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import '../models/tracking_models.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ThemeColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: TextButton(
                    onPressed: () => _showModeSelection(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppConstants.textSizeMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Main content
                      _buildMainContent(),

                      const SizedBox(height: AppConstants.paddingLarge),
                    ],
                  ),
                ),
              ),

              // Get started button (fixed at bottom)
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: _buildGetStartedButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // App icon with glow effect
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: AppConstants.paddingLarge),

        // App title
        const Text(
          'RefundTracker Pro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: AppConstants.primaryFont,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: AppConstants.paddingMedium),

        // App subtitle
        const Text(
          'Track your refunds with style and humor',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: AppConstants.textSizeLarge,
            fontFamily: AppConstants.primaryFont,
            height: 1.4,
          ),
        ),

        const SizedBox(height: AppConstants.paddingLarge),

        // Feature highlights
        _buildFeatureHighlights(),
      ],
    );
  }

  Widget _buildFeatureHighlights() {
    return Column(
      children: [
        _buildFeatureRow(
          Icons.track_changes_rounded,
          'Smart Tracking',
          'Track individual items or manage everything in one pool',
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        _buildFeatureRow(
          Icons.notifications_active_rounded,
          'Funny Alerts',
          'AI-powered humor that makes finance enjoyable',
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        _buildFeatureRow(
          Icons.security_rounded,
          'Data Protection',
          'Your financial data stays private and secure',
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
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
                    color: Colors.white,
                    fontSize: AppConstants.textSizeLarge,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConstants.primaryFont,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: AppConstants.textSizeMedium,
                    fontFamily: AppConstants.primaryFont,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showModeSelection(context),
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    color: ThemeColors.primaryColor,
                    fontSize: AppConstants.textSizeLarge,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.primaryFont,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: ThemeColors.primaryColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModeSelectionBottomSheet(),
    );
  }
}

class ModeSelectionBottomSheet extends StatefulWidget {
  const ModeSelectionBottomSheet({super.key});

  @override
  State<ModeSelectionBottomSheet> createState() =>
      _ModeSelectionBottomSheetState();
}

class _ModeSelectionBottomSheetState extends State<ModeSelectionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeColors.radiusXLarge),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Title
              const Text(
                'Choose Your Tracking Style',
                style: TextStyle(
                  fontSize: AppConstants.textSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              const Text(
                'Select how you want to track your refunds. You can change this anytime in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConstants.textSizeMedium,
                  color: ThemeColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Mode options
              _buildModeOption(
                context: context,
                mode: TrackingMode.perItem,
                title: 'Per-Item Tracking',
                subtitle:
                    'Track each expense individually with detailed progress',
                icon: Icons.inventory_2_rounded,
                color: ThemeColors.perItemAccent,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              _buildModeOption(
                context: context,
                mode: TrackingMode.pool,
                title: 'Pool Tracking',
                subtitle: 'Manage all expenses in one simple pool',
                icon: Icons.account_balance_wallet_rounded,
                color: ThemeColors.poolAccent,
              ),

              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required TrackingMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectMode(context, mode),
          borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(ThemeColors.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: AppConstants.iconSizeLarge,
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
                          fontSize: AppConstants.textSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: AppConstants.textSizeMedium,
                          color: ThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ThemeColors.textTertiary,
                  size: AppConstants.iconSizeMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectMode(BuildContext context, TrackingMode mode) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.switchMode(mode);

    // Mark app as done after mode selection
    await provider.markAppAsDone();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      });
    }
  }
}
