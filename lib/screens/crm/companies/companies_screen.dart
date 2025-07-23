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
  List<Company> _filteredCompanies = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _filteredCompanies = apiResponse.data!;
          _errorMessage = null;
        } else {
          _companies = [];
          _filteredCompanies = [];
          _errorMessage = apiResponse.message;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
        _companies = [];
        _filteredCompanies = [];
      });
    }
  }

  void _filterCompanies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCompanies = _companies;
      } else {
        _filteredCompanies = _companies
            .where((company) =>
                company.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
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

    if (_filteredCompanies.isEmpty && _companies.isNotEmpty) {
      return Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCompanies,
              decoration: InputDecoration(
                hintText: 'Search companies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterCompanies('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
          // Empty search results
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No companies match your search',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: _filterCompanies,
              decoration: InputDecoration(
                hintText: 'Search companies...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _filterCompanies('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCompanies,
            color: Colors.blue,
            backgroundColor: Colors.white,
            child: ListView.builder(
              itemCount: _filteredCompanies.length,
              itemBuilder: (context, index) {
                final company = _filteredCompanies[index];
                return _buildCompanyCard(company);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with company name and status
            Row(
              children: [
                // Company avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
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
              ],
            ),

            if (company.address != null ||
                company.phone != null ||
                company.postalCode != null ||
                company.website != null)
              const SizedBox(height: 12),

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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
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
