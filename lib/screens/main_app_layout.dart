import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/layout/sidebar_navigation.dart';
import 'crm/create_company_screen.dart';
import 'crm/create_contact_screen.dart';
import 'sales/create_opportunity_screen.dart';

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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/crm/contacts':
        return 'Contacts';
      case '/crm/companies':
        return 'Companies';
      case '/crm/suppliers':
        return 'Suppliers';
      case '/crm/products':
        return 'Products';
      case '/gtm/quota-planning':
        return 'Quota Planning';
      case '/gtm/sales-forecast':
        return 'Sales Forecast';
      case '/gtm/profit-loss':
        return 'Profit & Loss';
      case '/sales/opportunities':
        return 'Opportunities';
      case '/sales/activity-planner':
        return 'Activity Planner';
      case '/sales/invoices':
        return 'Invoices';
      case '/sales/proposals':
        return 'Proposals';
      default:
        return 'Dashboard';
    }
  }

  bool _shouldShowAddButton(String route) {
    return route == '/crm/companies' ||
        route == '/crm/contacts' ||
        route == '/sales/opportunities';
  }

  void _handleAddAction(String route) {
    if (route == '/crm/companies') {
      // Use proper navigation stack for create company screen
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => CreateCompanyScreen(
            onCompanyCreated: () {
              // Call the refresh method through the navigation controller
              _navigationController.refreshCompanies();
            },
          ),
        ),
      )
          .then((result) {
        // The refresh is now handled by the callback
        // No need to do anything here unless you want additional logic
      });
    } else if (route == '/crm/contacts') {
      // Use proper navigation stack for create contact screen
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => CreateContactScreen(
            onContactCreated: () {
              // Call the refresh method through the navigation controller
              _navigationController.refreshContacts();
            },
          ),
        ),
      )
          .then((result) {
        // The refresh is now handled by the callback
        // No need to do anything here unless you want additional logic
      });
    } else if (route == '/sales/opportunities') {
      // Use proper navigation stack for create opportunity screen
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => CreateOpportunityScreen(
            onOpportunityCreated: () {
              // Call the refresh method through the navigation controller
              _navigationController.refreshOpportunities();
            },
          ),
        ),
      )
          .then((result) {
        // The refresh is now handled by the callback
        // No need to do anything here unless you want additional logic
      });
    }
  }
}
