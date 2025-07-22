import 'package:flutter/material.dart';
import '../screens/crm/companies/create_company_screen.dart';
import '../screens/crm/contacts/create_contact_screen.dart';
import '../screens/sales/opportunities/create_opportunity_screen.dart';
import '../screens/sales/opportunities/opportunity_detail_screen.dart';
import '../screens/main_app_layout.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.createCompany:
        return MaterialPageRoute(
          builder: (_) => CreateCompanyScreen(
            onCompanyCreated: () {
              // Navigation will be handled by the calling screen
            },
          ),
        );

      case AppRoutes.createContact:
        return MaterialPageRoute(
          builder: (_) => CreateContactScreen(
            onContactCreated: () {
              // Navigation will be handled by the calling screen
            },
          ),
        );

      case AppRoutes.createOpportunity:
        return MaterialPageRoute(
          builder: (_) => CreateOpportunityScreen(
            onOpportunityCreated: () {
              // Navigation will be handled by the calling screen
            },
          ),
        );

      case AppRoutes.opportunityDetail:
        final String? opportunityId = settings.arguments as String?;
        if (opportunityId == null) {
          return _errorRoute('Opportunity ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => OpportunityDetailScreen(
            opportunityId: opportunityId,
          ),
        );

      // Default route (main app layout)
      default:
        return MaterialPageRoute(
          builder: (_) => const MainAppLayout(),
        );
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
