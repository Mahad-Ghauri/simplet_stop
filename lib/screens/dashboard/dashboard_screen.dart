import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/providers/progress/progress_provider.dart';
import 'package:simplet_stop/services/localization_service.dart';
import '../../utils/theme.dart';
import 'overview_tab.dart';
import 'journey_tab.dart';
import 'triggers_tab.dart';
import 'profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _tabs = [
    const OverviewTab(),
    const JourneyTab(),
    const TriggersTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _loadUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      progressProvider.loadProgress(authProvider.currentUser!.id);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocalizationService>(
      builder: (context, authProvider, localizationService, child) {
        if (authProvider.currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _tabs,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.surfaceColor,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondary,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard),
                label: localizationService.tr('dashboard.overview'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.timeline_outlined),
                activeIcon: const Icon(Icons.timeline),
                label: localizationService.tr('dashboard.journey'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.psychology_outlined),
                activeIcon: const Icon(Icons.psychology),
                label: localizationService.tr('dashboard.triggers'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: localizationService.tr('dashboard.profile'),
              ),
            ],
          ),
        );
      },
    );
  }
}
