import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/crm/contacts_screen.dart';
import '../screens/crm/companies_screen.dart';
import '../screens/crm/suppliers_screen.dart';
import '../screens/crm/products_screen.dart';
import '../screens/gtm/quota_planning_screen.dart';
import '../screens/gtm/sales_forecast_screen.dart';
import '../screens/gtm/profit_loss_screen.dart';
import '../screens/sales/opportunities_screen.dart';
import '../screens/sales/activity_planner_screen.dart';
import '../screens/sales/invoices_screen.dart';
import '../screens/sales/proposals_screen.dart';

class NavigationController extends ChangeNotifier {
  String _currentRoute = '/dashboard';
  Widget _currentScreen = const DashboardScreen();
  VoidCallback? _companiesRefreshCallback;
  VoidCallback? _contactsRefreshCallback;
  VoidCallback? _opportunitiesRefreshCallback;

  String get currentRoute => _currentRoute;
  Widget get currentScreen => _currentScreen;

  void setCompaniesRefreshCallback(VoidCallback callback) {
    _companiesRefreshCallback = callback;
  }

  void setContactsRefreshCallback(VoidCallback callback) {
    _contactsRefreshCallback = callback;
  }

  void setOpportunitiesRefreshCallback(VoidCallback callback) {
    _opportunitiesRefreshCallback = callback;
  }

  void refreshCompanies() {
    if (_companiesRefreshCallback != null) {
      _companiesRefreshCallback!();
    }
  }

  void refreshContacts() {
    if (_contactsRefreshCallback != null) {
      _contactsRefreshCallback!();
    }
  }

  void refreshOpportunities() {
    if (_opportunitiesRefreshCallback != null) {
      _opportunitiesRefreshCallback!();
    }
  }

  void navigateTo(String route) {
    if (_currentRoute == route) return;

    _currentRoute = route;

    switch (route) {
      case '/dashboard':
        _currentScreen = const DashboardScreen();
        break;
      case '/crm/contacts':
        _currentScreen = ContactsScreen(navigationController: this);
        break;
      case '/crm/companies':
        _currentScreen = CompaniesScreen(navigationController: this);
        break;
      case '/crm/suppliers':
        _currentScreen = const SuppliersScreen();
        break;
      case '/crm/products':
        _currentScreen = const ProductsScreen();
        break;
      case '/gtm/quota-planning':
        _currentScreen = const QuotaPlanningScreen();
        break;
      case '/gtm/sales-forecast':
        _currentScreen = const SalesForecastScreen();
        break;
      case '/gtm/profit-loss':
        _currentScreen = const ProfitLossScreen();
        break;
      case '/sales/opportunities':
        _currentScreen = OpportunitiesScreen(navigationController: this);
        break;
      case '/sales/activity-planner':
        _currentScreen = const ActivityPlannerScreen();
        break;
      case '/sales/invoices':
        _currentScreen = const InvoicesScreen();
        break;
      case '/sales/proposals':
        _currentScreen = const ProposalsScreen();
        break;
      default:
        _currentScreen = const DashboardScreen();
        _currentRoute = '/dashboard';
    }

    notifyListeners();
  }
}
