class AppRoutes {
  // Dashboard
  static const String dashboard = '/dashboard';

  // CRM Routes
  static const String companies = '/crm/companies';
  static const String createCompany = '/crm/companies/create';
  static const String contacts = '/crm/contacts';
  static const String createContact = '/crm/contacts/create';
  static const String suppliers = '/crm/suppliers';
  static const String products = '/crm/products';

  // Sales Routes
  static const String opportunities = '/sales/opportunities';
  static const String createOpportunity = '/sales/opportunities/create';
  static const String opportunityDetail = '/sales/opportunities/detail';
  static const String activityPlanner = '/sales/activity-planner';
  static const String invoices = '/sales/invoices';
  static const String proposals = '/sales/proposals';

  // GTM Routes
  static const String quotaPlanning = '/gtm/quota-planning';
  static const String salesForecast = '/gtm/sales-forecast';
  static const String profitLoss = '/gtm/profit-loss';

  // Route titles mapping
  static const Map<String, String> routeTitles = {
    dashboard: 'Dashboard',
    contacts: 'Contacts',
    companies: 'Companies',
    suppliers: 'Suppliers',
    products: 'Products',
    quotaPlanning: 'Quota Planning',
    salesForecast: 'Sales Forecast',
    profitLoss: 'Profit & Loss',
    opportunities: 'Opportunities',
    activityPlanner: 'Activity Planner',
    invoices: 'Invoices',
    proposals: 'Proposals',
  };

  // Routes that should show add button
  static const Set<String> routesWithAddButton = {
    companies,
    contacts,
    opportunities,
  };

  // Create routes mapping
  static const Map<String, String> createRoutes = {
    companies: createCompany,
    contacts: createContact,
    opportunities: createOpportunity,
  };
}
