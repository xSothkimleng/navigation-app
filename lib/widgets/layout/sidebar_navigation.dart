import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../screens/auth/auth_loading_screen.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/user.dart';

class SidebarNavigation extends StatefulWidget {
  final NavigationController navigationController;
  final VoidCallback? onClose;

  const SidebarNavigation({
    Key? key,
    required this.navigationController,
    this.onClose,
  }) : super(key: key);

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation>
    with TickerProviderStateMixin {
  bool _isCrmExpanded = false;
  bool _isGtmExpanded = false;
  bool _isSalesExpanded = false;
  User? _currentUser;

  late AnimationController _crmAnimationController;
  late AnimationController _gtmAnimationController;
  late AnimationController _salesAnimationController;

  late Animation<double> _crmHeightAnimation;
  late Animation<double> _gtmHeightAnimation;
  late Animation<double> _salesHeightAnimation;

  @override
  void initState() {
    super.initState();
    widget.navigationController.addListener(_onNavigationChanged);
    _loadCurrentUser();

    // Initialize animation controllers
    _crmAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _gtmAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _salesAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize height animations
    _crmHeightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _crmAnimationController,
      curve: Curves.easeInOut,
    ));

    _gtmHeightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gtmAnimationController,
      curve: Curves.easeInOut,
    ));

    _salesHeightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _salesAnimationController,
      curve: Curves.easeInOut,
    ));

    // Set initial animation states based on current route
    final route = widget.navigationController.currentRoute;
    if (route.startsWith('/crm/')) {
      _isCrmExpanded = true;
      _crmAnimationController.value = 1.0;
    }
    if (route.startsWith('/gtm/')) {
      _isGtmExpanded = true;
      _gtmAnimationController.value = 1.0;
    }
    if (route.startsWith('/sales/')) {
      _isSalesExpanded = true;
      _salesAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    widget.navigationController.removeListener(_onNavigationChanged);
    _crmAnimationController.dispose();
    _gtmAnimationController.dispose();
    _salesAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await UserService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
      if (mounted) {
        setState(() {
          _currentUser = null;
        });
      }
    }
  }

  void _onNavigationChanged() {
    if (!mounted) return;

    setState(() {
      // Update expansion states based on current route
      final route = widget.navigationController.currentRoute;
      final wasCrmExpanded = _isCrmExpanded;
      final wasGtmExpanded = _isGtmExpanded;
      final wasSalesExpanded = _isSalesExpanded;

      _isCrmExpanded = route.startsWith('/crm/');
      _isGtmExpanded = route.startsWith('/gtm/');
      _isSalesExpanded = route.startsWith('/sales/');

      // Animate section changes only if controllers are initialized
      if (_crmAnimationController.isCompleted ||
          _crmAnimationController.isDismissed) {
        if (_isCrmExpanded != wasCrmExpanded) {
          if (_isCrmExpanded) {
            _crmAnimationController.forward();
          } else {
            _crmAnimationController.reverse();
          }
        }
      }

      if (_gtmAnimationController.isCompleted ||
          _gtmAnimationController.isDismissed) {
        if (_isGtmExpanded != wasGtmExpanded) {
          if (_isGtmExpanded) {
            _gtmAnimationController.forward();
          } else {
            _gtmAnimationController.reverse();
          }
        }
      }

      if (_salesAnimationController.isCompleted ||
          _salesAnimationController.isDismissed) {
        if (_isSalesExpanded != wasSalesExpanded) {
          if (_isSalesExpanded) {
            _salesAnimationController.forward();
          } else {
            _salesAnimationController.reverse();
          }
        }
      }
    });
  }

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
  ];

  final List<NavigationGroup> _navigationGroups = [
    NavigationGroup(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'CRM',
      children: [
        NavigationItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Contacts',
          route: '/crm/contacts',
        ),
        NavigationItem(
          icon: Icons.business_outlined,
          selectedIcon: Icons.business,
          label: 'Companies',
          route: '/crm/companies',
        ),
        NavigationItem(
          icon: Icons.store_outlined,
          selectedIcon: Icons.store,
          label: 'Suppliers',
          route: '/crm/suppliers',
        ),
        NavigationItem(
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          label: 'Products',
          route: '/crm/products',
        ),
      ],
    ),
    NavigationGroup(
      icon: Icons.trending_up_outlined,
      selectedIcon: Icons.trending_up,
      label: 'GTM',
      children: [
        NavigationItem(
          icon: Icons.timeline_outlined,
          selectedIcon: Icons.timeline,
          label: 'Quota planning',
          route: '/gtm/quota-planning',
        ),
        NavigationItem(
          icon: Icons.analytics_outlined,
          selectedIcon: Icons.analytics,
          label: 'Sales forecast',
          route: '/gtm/sales-forecast',
        ),
        NavigationItem(
          icon: Icons.assessment_outlined,
          selectedIcon: Icons.assessment,
          label: 'Profit & Loss',
          route: '/gtm/profit-loss',
        ),
      ],
    ),
    NavigationGroup(
      icon: Icons.attach_money_outlined,
      selectedIcon: Icons.attach_money,
      label: 'Sales',
      children: [
        NavigationItem(
          icon: Icons.business_center_outlined,
          selectedIcon: Icons.business_center,
          label: 'Opportunities',
          route: '/sales/opportunities',
        ),
        NavigationItem(
          icon: Icons.event_note_outlined,
          selectedIcon: Icons.event_note,
          label: 'Activity Planner',
          route: '/sales/activity-planner',
        ),
        NavigationItem(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          label: 'Invoices',
          route: '/sales/invoices',
        ),
        NavigationItem(
          icon: Icons.description_outlined,
          selectedIcon: Icons.description,
          label: 'Proposals',
          route: '/sales/proposals',
        ),
      ],
    ),
  ];

  Future<void> _handleLogout() async {
    try {
      final result = await AuthService.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthLoadingScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Logout failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRoute(String route) {
    widget.navigationController.navigateTo(route);
    // Close drawer after navigation on mobile
    if (widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            height: 80,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image not found
                      return const Icon(
                        Icons.navigation,
                        size: 32,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Salesquake',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                // Dashboard
                _buildNavigationTile(_navigationItems[0]),
                const SizedBox(height: 8),

                // CRM Section
                _buildExpandableSection(
                  group: _navigationGroups[0],
                  isExpanded: _isCrmExpanded,
                  heightAnimation: _crmHeightAnimation,
                  onToggle: () {
                    setState(() => _isCrmExpanded = !_isCrmExpanded);
                    if (_isCrmExpanded) {
                      _crmAnimationController.forward();
                    } else {
                      _crmAnimationController.reverse();
                    }
                  },
                ),
                const SizedBox(height: 8),

                // GTM Section
                _buildExpandableSection(
                  group: _navigationGroups[1],
                  isExpanded: _isGtmExpanded,
                  heightAnimation: _gtmHeightAnimation,
                  onToggle: () {
                    setState(() => _isGtmExpanded = !_isGtmExpanded);
                    if (_isGtmExpanded) {
                      _gtmAnimationController.forward();
                    } else {
                      _gtmAnimationController.reverse();
                    }
                  },
                ),
                const SizedBox(height: 8),

                // Sales Section
                _buildExpandableSection(
                  group: _navigationGroups[2],
                  isExpanded: _isSalesExpanded,
                  heightAnimation: _salesHeightAnimation,
                  onToggle: () {
                    setState(() => _isSalesExpanded = !_isSalesExpanded);
                    if (_isSalesExpanded) {
                      _salesAnimationController.forward();
                    } else {
                      _salesAnimationController.reverse();
                    }
                  },
                ),
              ],
            ),
          ),

          // User Profile and Logout Section
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                // User Profile
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Profile Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: _currentUser?.hasProfileImage == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  _currentUser!.profileImage!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      _currentUser?.initials ?? 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                _currentUser?.initials ?? 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser?.fullName.isNotEmpty == true
                                  ? _currentUser!.fullName
                                  : _currentUser != null
                                      ? _currentUser!.fullName
                                      : 'Loading...',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentUser?.email ?? 'Loading...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Logout Button - Simple and left-aligned
                InkWell(
                  onTap: _handleLogout,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 20,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(NavigationItem item) {
    final isSelected = widget.navigationController.currentRoute == item.route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: SizedBox(
          width: 20,
          child: Icon(
            isSelected ? item.selectedIcon : item.icon,
            color: isSelected ? Colors.blue : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.blue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        visualDensity: VisualDensity.compact,
        onTap: () => _navigateToRoute(item.route),
      ),
    );
  }

  Widget _buildExpandableSection({
    required NavigationGroup group,
    required bool isExpanded,
    required Animation<double> heightAnimation,
    required VoidCallback onToggle,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            isExpanded ? group.selectedIcon : group.icon,
            color: isExpanded ? Colors.blue : Colors.grey[600],
            size: 20,
          ),
          title: Text(
            group.label,
            style: TextStyle(
              color: isExpanded ? Colors.blue : Colors.grey[800],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: VisualDensity.compact,
          onTap: () {
            onToggle();
            // Only navigate if we're expanding a section that's not already showing the right content
            // Don't auto-navigate when just toggling
          },
        ),
        AnimatedBuilder(
          animation: heightAnimation,
          builder: (context, child) {
            return ClipRect(
              child: SizeTransition(
                sizeFactor: heightAnimation,
                axisAlignment: -1.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: group.children
                        .map((item) => _buildNavigationTile(item))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

class NavigationGroup {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final List<NavigationItem> children;

  NavigationGroup({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.children,
  });
}
