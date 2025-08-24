import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _fadeController.forward().then((_) {
        _fadeController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final hasAgingDebts =
        provider.getItemsWithAgingDebts(AppConstants.criticalDays).isNotEmpty;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildModernBottomNav(hasAgingDebts),
    );
  }

  Widget _buildModernBottomNav(bool hasAgingDebts) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: ThemeColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ThemeColors.radiusXLarge),
          topRight: Radius.circular(ThemeColors.radiusXLarge),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_rounded,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                hasNotification: false,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.settings_rounded,
                activeIcon: Icons.settings,
                label: 'Settings',
                hasNotification: hasAgingDebts,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool hasNotification,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _onTabTapped(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? ThemeColors.navSelected.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeColors.radiusFull),
          border: isActive
              ? Border.all(
                  color: ThemeColors.navSelected.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? ThemeColors.navSelected
                      : ThemeColors.navUnselected,
                  size: isActive ? 24.0 : 22.0,
                ),
                if (isActive) ...[
                  const SizedBox(width: 8.0),
                  Text(
                    label,
                    style: const TextStyle(
                      color: ThemeColors.navSelected,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ],
            ),
            // Notification indicator
            if (hasNotification)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ThemeColors.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeColors.navBackground,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
