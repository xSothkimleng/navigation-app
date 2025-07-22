import 'package:flutter/material.dart';
import 'package:salesquake_app/models/company.dart';
import 'package:salesquake_app/services/company_service.dart';
import 'package:salesquake_app/controllers/navigation_controller.dart';

class CompaniesScreen extends StatefulWidget {
  final NavigationController? navigationController;

  const CompaniesScreen({Key? key, this.navigationController})
      : super(key: key);

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  List<Company> _companies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Register the refresh callback with the navigation controller
    if (widget.navigationController != null) {
      widget.navigationController!
          .setCompaniesRefreshCallback(refreshCompanies);
    }

    _loadCompanies();
  }

  // Public method to refresh companies from external calls
  void refreshCompanies() {
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiResponse = await CompanyService.getCompanies();

      setState(() {
        if (apiResponse.data != null) {
          _companies = apiResponse.data!;
          _errorMessage = null;
        } else {
          _companies = [];
          _errorMessage = apiResponse.message;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
        _companies = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading companies',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCompanies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_companies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No companies found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCompanies,
      color: Colors.blue,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _companies.length,
        itemBuilder: (context, index) {
          final company = _companies[index];
          return _buildCompanyCard(company);
        },
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Color(0xFFC5C6CC),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with company name and status
            Row(
              children: [
                // Company avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (company.country?.name != null)
                        Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              company.country!.name!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: company.isActive
                        ? const Color(0xFFEAF2FF)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    company.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      color: company.isActive
                          ? const Color(0xFF006FFD)
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            if (company.address != null ||
                company.phone != null ||
                company.postalCode != null ||
                company.website != null)
              const SizedBox(height: 16),

            // Company details
            if (company.address != null)
              _buildInfoRow(
                Icons.location_on_outlined,
                company.address!,
              ),

            // Phone
            if (company.phone != null)
              _buildInfoRow(
                Icons.phone_outlined,
                company.phone!,
              ),

            // Company ID or Postal Code
            if (company.postalCode != null)
              _buildInfoRow(
                Icons.tag,
                company.postalCode!,
              ),

            // Website
            if (company.website != null)
              _buildInfoRow(
                Icons.language,
                company.website!,
                isUrl: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isUrl ? Colors.blue[600] : Colors.black87,
                  decoration: isUrl ? TextDecoration.underline : null,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
