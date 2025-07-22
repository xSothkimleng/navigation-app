import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/crm/contacts/contacts_screen.dart';
import '../screens/crm/companies/companies_screen.dart';
import '../screens/crm/suppliers_screen.dart';
import '../screens/crm/products_screen.dart';
import '../screens/gtm/quota_planning_screen.dart';
import '../screens/gtm/sales_forecast_screen.dart';
import '../screens/gtm/profit_loss_screen.dart';
import '../screens/sales/opportunities/opportunities_screen.dart';
import '../screens/sales/activity_planner_screen.dart';
import '../screens/sales/invoices_screen.dart';
import '../screens/sales/proposals_screen.dart';
import '../routes/app_routes.dart';

class NavigationController extends ChangeNotifier {
  String _currentRoute = AppRoutes.dashboard;
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

  void refreshCurrentScreen() {
    switch (_currentRoute) {
      case AppRoutes.companies:
        refreshCompanies();
        break;
      case AppRoutes.contacts:
        refreshContacts();
        break;
      case AppRoutes.opportunities:
        refreshOpportunities();
        break;
    }
  }

  void navigateTo(String route) {
    if (_currentRoute == route) return;

    _currentRoute = route;

    switch (route) {
      case AppRoutes.dashboard:
        _currentScreen = const DashboardScreen();
        break;
      case AppRoutes.contacts:
        _currentScreen = ContactsScreen(navigationController: this);
        break;
      case AppRoutes.companies:
        _currentScreen = CompaniesScreen(navigationController: this);
        break;
      case AppRoutes.suppliers:
        _currentScreen = const SuppliersScreen();
        break;
      case AppRoutes.products:
        _currentScreen = const ProductsScreen();
        break;
      case AppRoutes.quotaPlanning:
        _currentScreen = const QuotaPlanningScreen();
        break;
      case AppRoutes.salesForecast:
        _currentScreen = const SalesForecastScreen();
        break;
      case AppRoutes.profitLoss:
        _currentScreen = const ProfitLossScreen();
        break;
      case AppRoutes.opportunities:
        _currentScreen = OpportunitiesScreen(navigationController: this);
        break;
      case AppRoutes.activityPlanner:
        _currentScreen = const ActivityPlannerScreen();
        break;
      case AppRoutes.invoices:
        _currentScreen = const InvoicesScreen();
        break;
      case AppRoutes.proposals:
        _currentScreen = const ProposalsScreen();
        break;
      default:
        _currentScreen = const DashboardScreen();
        _currentRoute = AppRoutes.dashboard;
    }

    notifyListeners();
  }
}
