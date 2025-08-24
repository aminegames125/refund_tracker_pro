import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/tracking_models.dart';
import '../widgets/mode_specific_dashboard.dart';
import '../widgets/pool_dashboard.dart';




class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final mode = provider.settings.trackingMode;

    return Scaffold(
      body: _buildDashboardContent(context, mode),
    );
  }

  Widget _buildDashboardContent(BuildContext context, TrackingMode mode) {
    switch (mode) {
      case TrackingMode.perItem:
        return const PerItemDashboard();
      case TrackingMode.pool:
        return const PoolDashboard();
      case TrackingMode.hybrid:
        // Hybrid mode disabled - fallback to per-item
        return const PerItemDashboard();
      

    }
  }
}
