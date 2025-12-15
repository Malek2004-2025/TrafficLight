import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/alert_card_widget.dart';
import './widgets/alert_details_bottom_sheet.dart';
import './widgets/proximity_filter_widget.dart';

/// Dynamic Alerts Screen - Manages critical notifications with proximity filtering
/// and automated prioritization for driver safety
class DynamicAlertsScreen extends StatefulWidget {
  const DynamicAlertsScreen({Key? key}) : super(key: key);

  @override
  State<DynamicAlertsScreen> createState() => _DynamicAlertsScreenState();
}

class _DynamicAlertsScreenState extends State<DynamicAlertsScreen>
    with TickerProviderStateMixin {
  int _currentBottomNavIndex = 2; // Alerts tab
  int _selectedProximityFilter = 1; // 1km default
  int _currentTabIndex = 0;
  late TabController _tabController;
  bool _isRefreshing = false;

  // Mock data for alerts
  final List<Map<String, dynamic>> _allAlerts = [
    {
      "id": "alert_001",
      "type": "emergency",
      "title": "Accident signalé",
      "description":
          "Collision entre deux véhicules sur la voie de droite. Services d'urgence en route.",
      "distance": 450,
      "timestamp": DateTime.now().subtract(Duration(minutes: 2)),
      "severity": "critical",
      "icon": "warning",
      "location": {"lat": 48.8566, "lng": 2.3522},
      "isRead": false,
      "canDismiss": false,
      "affectedLights": ["TL_001", "TL_002"],
      "estimatedClearTime": DateTime.now().add(Duration(minutes: 25)),
    },
    {
      "id": "alert_002",
      "type": "priority_vehicle",
      "title": "Véhicule prioritaire détecté",
      "description":
          "Ambulance approchant rapidement. Préparez-vous à céder le passage.",
      "distance": 280,
      "timestamp": DateTime.now().subtract(Duration(minutes: 1)),
      "severity": "high",
      "icon": "local_hospital",
      "location": {"lat": 48.8576, "lng": 2.3532},
      "isRead": false,
      "canDismiss": false,
      "vehicleType": "ambulance",
      "estimatedArrival": DateTime.now().add(Duration(seconds: 45)),
    },
    {
      "id": "alert_003",
      "type": "traffic_update",
      "title": "Congestion importante",
      "description":
          "Trafic dense détecté sur votre itinéraire. Temps d'attente estimé: 8 minutes.",
      "distance": 650,
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
      "severity": "medium",
      "icon": "traffic",
      "location": {"lat": 48.8586, "lng": 2.3542},
      "isRead": false,
      "canDismiss": true,
      "affectedLights": ["TL_003", "TL_004", "TL_005"],
      "trafficDensity": 0.85,
    },
    {
      "id": "alert_004",
      "type": "priority_vehicle",
      "title": "Véhicule de police en approche",
      "description":
          "Véhicule de police avec sirène activée. Restez vigilant et cédez le passage.",
      "distance": 520,
      "timestamp": DateTime.now().subtract(Duration(minutes: 3)),
      "severity": "high",
      "icon": "local_police",
      "location": {"lat": 48.8596, "lng": 2.3552},
      "isRead": false,
      "canDismiss": false,
      "vehicleType": "police",
      "estimatedArrival": DateTime.now().add(Duration(seconds: 90)),
    },
    {
      "id": "alert_005",
      "type": "traffic_update",
      "title": "Feu de circulation en panne",
      "description":
          "Le feu de circulation à l'intersection principale est hors service. Prudence requise.",
      "distance": 890,
      "timestamp": DateTime.now().subtract(Duration(minutes: 8)),
      "severity": "medium",
      "icon": "traffic",
      "location": {"lat": 48.8606, "lng": 2.3562},
      "isRead": true,
      "canDismiss": true,
      "affectedLights": ["TL_006"],
      "maintenanceScheduled": DateTime.now().add(Duration(hours: 2)),
    },
    {
      "id": "alert_006",
      "type": "emergency",
      "title": "Travaux routiers d'urgence",
      "description":
          "Réparation d'urgence de la chaussée. Voie fermée, déviation en place.",
      "distance": 1200,
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "severity": "high",
      "icon": "construction",
      "location": {"lat": 48.8616, "lng": 2.3572},
      "isRead": true,
      "canDismiss": true,
      "affectedLights": ["TL_007", "TL_008"],
      "estimatedClearTime": DateTime.now().add(Duration(hours: 3)),
    },
    {
      "id": "alert_007",
      "type": "traffic_update",
      "title": "Optimisation de l'itinéraire disponible",
      "description":
          "Un itinéraire alternatif plus rapide a été détecté. Gain de temps estimé: 4 minutes.",
      "distance": 350,
      "timestamp": DateTime.now().subtract(Duration(minutes: 1)),
      "severity": "low",
      "icon": "alt_route",
      "location": {"lat": 48.8626, "lng": 2.3582},
      "isRead": false,
      "canDismiss": true,
      "timeSaved": Duration(minutes: 4),
      "alternativeRoute": true,
    },
    {
      "id": "alert_008",
      "type": "priority_vehicle",
      "title": "Camion de pompiers détecté",
      "description":
          "Véhicule d'urgence des pompiers approchant. Dégagez la voie immédiatement.",
      "distance": 1850,
      "timestamp": DateTime.now().subtract(Duration(minutes: 12)),
      "severity": "high",
      "icon": "fire_truck",
      "location": {"lat": 48.8636, "lng": 2.3592},
      "isRead": true,
      "canDismiss": false,
      "vehicleType": "fire_truck",
      "estimatedArrival": DateTime.now().add(Duration(minutes: 3)),
    },
  ];

  List<Map<String, dynamic>> get _filteredAlerts {
    final proximityThresholds = [500, 1000, 2000];
    final maxDistance = proximityThresholds[_selectedProximityFilter];

    return _allAlerts
        .where((alert) => (alert["distance"] as int) <= maxDistance)
        .toList();
  }

  List<Map<String, dynamic>> get _criticalAlerts {
    return _filteredAlerts
        .where((alert) => alert["severity"] == "critical")
        .toList();
  }

  List<Map<String, dynamic>> get _priorityAlerts {
    return _filteredAlerts
        .where(
            (alert) => alert["type"] == "priority_vehicle" && !alert["isRead"])
        .toList();
  }

  List<Map<String, dynamic>> get _trafficAlerts {
    return _filteredAlerts
        .where((alert) =>
            alert["type"] == "traffic_update" ||
            (alert["type"] == "emergency" && alert["isRead"]))
        .toList();
  }

  int get _unreadCount {
    return _filteredAlerts.where((alert) => !alert["isRead"]).length;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate Firebase Cloud Messaging update
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alertes mises à jour'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    HapticFeedback.lightImpact();

    // Mark as read
    setState(() {
      alert["isRead"] = true;
    });

    // Show bottom sheet with details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertDetailsBottomSheet(alert: alert),
    );
  }

  void _handleAlertDismiss(Map<String, dynamic> alert) {
    if (!alert["canDismiss"]) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _allAlerts.remove(alert);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alerte supprimée'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            setState(() {
              _allAlerts.add(alert);
            });
          },
        ),
      ),
    );
  }

  void _handleAlertMarkAsRead(Map<String, dynamic> alert) {
    HapticFeedback.lightImpact();

    setState(() {
      alert["isRead"] = true;
    });
  }

  void _handleAlertLongPress(Map<String, dynamic> alert) {
    HapticFeedback.heavyImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContextMenu(alert),
    );
  }

  Widget _buildContextMenu(Map<String, dynamic> alert) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2.h),
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Color(0xFFB0BEC5).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem(
              icon: 'navigation',
              label: 'Naviguer vers l\'emplacement',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ai-dynamic-route-screen');
              },
            ),
            _buildContextMenuItem(
              icon: 'share',
              label: 'Partager l\'alerte',
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            _buildContextMenuItem(
              icon: 'report',
              label: 'Signaler faux positif',
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signalement envoyé'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (alert["canDismiss"])
              _buildContextMenuItem(
                icon: 'delete',
                label: 'Supprimer l\'alerte',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _handleAlertDismiss(alert);
                },
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: isDestructive ? AppTheme.errorColor : Color(0xFFB0BEC5),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDestructive
                      ? AppTheme.errorColor
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBarWithStatus(
        title: 'Alertes Dynamiques',
        statusText: _unreadCount > 0
            ? '$_unreadCount non lues'
            : 'Toutes les alertes lues',
        statusColor:
            _unreadCount > 0 ? AppTheme.warningColor : AppTheme.successColor,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: Column(
          children: [
            // Proximity filter chips
            ProximityFilterWidget(
              selectedIndex: _selectedProximityFilter,
              onFilterChanged: (index) {
                setState(() {
                  _selectedProximityFilter = index;
                });
                HapticFeedback.selectionClick();
              },
            ),
            SizedBox(height: 2.h),
            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF2A2A2A),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Color(0xFFB0BEC5),
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Critiques'),
                        if (_criticalAlerts.isNotEmpty) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_criticalAlerts.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Prioritaires'),
                        if (_priorityAlerts.isNotEmpty) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_priorityAlerts.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Trafic'),
                        if (_trafficAlerts.isNotEmpty) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_trafficAlerts.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAlertList(_criticalAlerts),
                  _buildAlertList(_priorityAlerts),
                  _buildAlertList(_trafficAlerts),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildAlertList(List<Map<String, dynamic>> alerts) {
    if (alerts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: alerts.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return AlertCardWidget(
          alert: alert,
          onTap: () => _handleAlertTap(alert),
          onDismiss: () => _handleAlertDismiss(alert),
          onMarkAsRead: () => _handleAlertMarkAsRead(alert),
          onLongPress: () => _handleAlertLongPress(alert),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'notifications_off',
            size: 64,
            color: Color(0xFFB0BEC5).withValues(alpha: 0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            'Aucune alerte',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Color(0xFFB0BEC5),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Toutes les alertes ont été traitées',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Color(0xFFB0BEC5).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
