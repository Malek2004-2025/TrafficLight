import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import 'widgets/ai_recommendation_card_widget.dart';
import 'widgets/fluidity_score_card_widget.dart';
import 'widgets/statistic_card_widget.dart';
import 'widgets/traffic_density_chart_widget.dart';

/// Dynamic Statistics and AI Screen
/// Displays animated analytics dashboard with traffic metrics and AI recommendations
class DynamicStatisticsAndAiScreen extends StatefulWidget {
  const DynamicStatisticsAndAiScreen({Key? key}) : super(key: key);

  @override
  State<DynamicStatisticsAndAiScreen> createState() =>
      _DynamicStatisticsAndAiScreenState();
}

class _DynamicStatisticsAndAiScreenState
    extends State<DynamicStatisticsAndAiScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3;
  bool _isRefreshing = false;

  // Mock data for statistics
  final Map<String, dynamic> _statisticsData = {
    'fluidityScore': 78.0,
    'fluidityTrend': '↑ +5% cette semaine',
    'averageWaitTime': '2.3',
    'waitTimeChange': '+0.2 min',
    'waitTimeChartData': [2.1, 2.5, 2.3, 2.8, 2.4, 2.2, 2.3],
    'totalTrips': '156',
    'tripsChange': '+12',
    'tripsChartData': [140.0, 145.0, 150.0, 148.0, 152.0, 154.0, 156.0],
    'timeSaved': '3.2',
    'timeSavedChange': '+0.5 h',
    'timeSavedChartData': [2.5, 2.8, 3.0, 2.9, 3.1, 3.0, 3.2],
    'densityDataDay': [
      {'label': '6h', 'value': 45},
      {'label': '9h', 'value': 85},
      {'label': '12h', 'value': 60},
      {'label': '15h', 'value': 70},
      {'label': '18h', 'value': 90},
      {'label': '21h', 'value': 40},
    ],
    'densityDataWeek': [
      {'label': 'Lun', 'value': 75},
      {'label': 'Mar', 'value': 80},
      {'label': 'Mer', 'value': 78},
      {'label': 'Jeu', 'value': 82},
      {'label': 'Ven', 'value': 85},
      {'label': 'Sam', 'value': 60},
      {'label': 'Dim', 'value': 55},
    ],
    'densityDataMonth': [
      {'label': 'S1', 'value': 70},
      {'label': 'S2', 'value': 75},
      {'label': 'S3', 'value': 78},
      {'label': 'S4', 'value': 80},
    ],
    'aiRecommendations': [
      {
        'title': 'Meilleur Moment de Départ',
        'description':
            'Partez 15 minutes plus tôt demain matin pour éviter le pic de trafic à 8h30.',
        'actionLabel': 'Définir Rappel',
        'icon': Icons.schedule,
      },
      {
        'title': 'Itinéraire Alternatif',
        'description':
            'Utilisez la Route B pour économiser 8 minutes en moyenne pendant les heures de pointe.',
        'actionLabel': 'Voir Itinéraire',
        'icon': Icons.route,
      },
      {
        'title': 'Optimisation Hebdomadaire',
        'description':
            'Vos trajets du vendredi sont 20% plus lents. Envisagez de partir 10 minutes plus tôt.',
        'actionLabel': 'Analyser',
        'icon': Icons.lightbulb_outline,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(Duration(milliseconds: 1500));

    setState(() => _isRefreshing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Statistiques mises à jour',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationSettings() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildNotificationSettingsSheet(),
    );
  }

  Widget _buildNotificationSettingsSheet() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Paramètres des Alertes IA',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.15,
            ),
          ),
          SizedBox(height: 3.h),
          _buildNotificationToggle(
            'Recommandations de Départ',
            'Recevoir des suggestions pour les meilleurs moments de départ',
            true,
            theme,
          ),
          SizedBox(height: 2.h),
          _buildNotificationToggle(
            'Alertes d\'Itinéraire',
            'Notifications sur les itinéraires alternatifs optimaux',
            true,
            theme,
          ),
          SizedBox(height: 2.h),
          _buildNotificationToggle(
            'Analyses Hebdomadaires',
            'Résumé hebdomadaire de vos statistiques de conduite',
            false,
            theme,
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00E5FF),
                foregroundColor: Color(0xFF000000),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Enregistrer',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.25,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String description,
    bool initialValue,
    ThemeData theme,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isEnabled = initialValue;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.1,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.4,
                      height: 1.33,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            Switch(
              value: isEnabled,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => isEnabled = value);
              },
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getCurrentDensityData() {
    switch (_tabController.index) {
      case 0:
        return (_statisticsData['densityDataDay'] as List)
            .cast<Map<String, dynamic>>();
      case 1:
        return (_statisticsData['densityDataWeek'] as List)
            .cast<Map<String, dynamic>>();
      case 2:
        return (_statisticsData['densityDataMonth'] as List)
            .cast<Map<String, dynamic>>();
      default:
        return (_statisticsData['densityDataDay'] as List)
            .cast<Map<String, dynamic>>();
    }
  }

  String _getCurrentTimeRange() {
    switch (_tabController.index) {
      case 0:
        return 'Aujourd\'hui';
      case 1:
        return 'Cette Semaine';
      case 2:
        return 'Ce Mois';
      default:
        return 'Aujourd\'hui';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Statistiques & IA',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: theme.appBarTheme.foregroundColor,
            letterSpacing: 0.15,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xFF00E5FF),
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: Color(0xFF00E5FF),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.25,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.25,
              ),
              tabs: [
                Tab(text: 'Jour'),
                Tab(text: 'Semaine'),
                Tab(text: 'Mois'),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Color(0xFF00E5FF),
        backgroundColor: theme.colorScheme.surface,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FluidityScoreCardWidget(
                score: _statisticsData['fluidityScore'] as double,
                trend: _statisticsData['fluidityTrend'] as String,
              ),
              SizedBox(height: 3.h),
              Text(
                'Statistiques de Conduite',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.15,
                ),
              ),
              SizedBox(height: 2.h),
              StatisticCardWidget(
                title: 'Temps d\'Attente Moyen',
                value: _statisticsData['averageWaitTime'] as String,
                unit: 'min',
                change: _statisticsData['waitTimeChange'] as String,
                chartData: (_statisticsData['waitTimeChartData'] as List)
                    .cast<double>(),
                chartColor: Color(0xFF00E5FF),
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              SizedBox(height: 2.h),
              StatisticCardWidget(
                title: 'Trajets Effectués',
                value: _statisticsData['totalTrips'] as String,
                unit: 'trajets',
                change: _statisticsData['tripsChange'] as String,
                chartData:
                    (_statisticsData['tripsChartData'] as List).cast<double>(),
                chartColor: Color(0xFF00C853),
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              SizedBox(height: 2.h),
              StatisticCardWidget(
                title: 'Temps Économisé',
                value: _statisticsData['timeSaved'] as String,
                unit: 'heures',
                change: _statisticsData['timeSavedChange'] as String,
                chartData: (_statisticsData['timeSavedChartData'] as List)
                    .cast<double>(),
                chartColor: Color(0xFFFFD600),
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              SizedBox(height: 3.h),
              TrafficDensityChartWidget(
                densityData: _getCurrentDensityData(),
                timeRange: _getCurrentTimeRange(),
              ),
              SizedBox(height: 3.h),
              Text(
                'Recommandations IA',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.15,
                ),
              ),
              SizedBox(height: 2.h),
              ...(_statisticsData['aiRecommendations'] as List)
                  .map((recommendation) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: AiRecommendationCardWidget(
                    title: recommendation['title'] as String,
                    description: recommendation['description'] as String,
                    actionLabel: recommendation['actionLabel'] as String,
                    icon: recommendation['icon'] as IconData,
                    onActionTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fonctionnalité en cours de développement',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Color(0xFF2A2A2A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNotificationSettings,
        backgroundColor: Color(0xFF00E5FF),
        foregroundColor: Color(0xFF000000),
        elevation: 4.0,
        child: CustomIconWidget(
          iconName: 'notifications',
          color: Color(0xFF000000),
          size: 24,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
      ),
    );
  }
}
