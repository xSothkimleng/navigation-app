import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/layout/sidebar_navigation.dart';
import '../routes/app_routes.dart';

class MainAppLayout extends StatefulWidget {
  const MainAppLayout({Key? key}) : super(key: key);

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout>
    with TickerProviderStateMixin {
  final NavigationController _navigationController = NavigationController();
  bool _isDrawerOpen = false;
  late AnimationController _drawerAnimationController;
  late Animation<Offset> _drawerSlideAnimation;
  late Animation<double> _backdropOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _backdropOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _drawerAnimationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });

    if (_isDrawerOpen) {
      _drawerAnimationController.forward();
    } else {
      _drawerAnimationController.reverse();
    }
  }

  void _closeDrawer() {
    if (_isDrawerOpen) {
      setState(() {
        _isDrawerOpen = false;
      });
      _drawerAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Main content area
              Column(
                children: [
                  // Top header
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Left side - Hamburger menu or back button
                        AnimatedBuilder(
                          animation: _navigationController,
                          builder: (context, child) {
                            return IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: _toggleDrawer,
                            );
                          },
                        ),
                        // Page title (centered)
                        Expanded(
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _navigationController,
                              builder: (context, child) {
                                return Text(
                                  _getPageTitle(
                                      _navigationController.currentRoute),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Right side - Add button or balance space
                        AnimatedBuilder(
                          animation: _navigationController,
                          builder: (context, child) {
                            final route = _navigationController.currentRoute;
                            if (_shouldShowAddButton(route)) {
                              return IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _handleAddAction(route),
                              );
                            } else {
                              return const SizedBox(width: 48);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 24, top: 24, right: 24),
                      child: AnimatedBuilder(
                        animation: _navigationController,
                        builder: (context, child) {
                          return _navigationController.currentScreen;
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Dark backdrop
              if (_isDrawerOpen)
                AnimatedBuilder(
                  animation: _backdropOpacityAnimation,
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: _closeDrawer,
                      child: Container(
                        color: Colors.black
                            .withValues(alpha: _backdropOpacityAnimation.value),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    );
                  },
                ),

              // Drawer overlay
              AnimatedBuilder(
                animation: _drawerSlideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _drawerSlideAnimation,
                    child: SidebarNavigation(
                      navigationController: _navigationController,
                      onClose: _closeDrawer,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPageTitle(String route) {
    return AppRoutes.routeTitles[route] ?? 'Dashboard';
  }

  bool _shouldShowAddButton(String route) {
    return AppRoutes.routesWithAddButton.contains(route);
  }

  void _handleAddAction(String route) {
    final createRoute = AppRoutes.createRoutes[route];
    if (createRoute != null) {
      Navigator.pushNamed(context, createRoute).then((_) {
        // Auto-refresh current screen
        _navigationController.refreshCurrentScreen();
      });
    }
  }
}
