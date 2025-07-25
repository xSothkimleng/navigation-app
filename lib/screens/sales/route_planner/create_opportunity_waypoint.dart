import 'package:flutter/material.dart';
import 'package:salesquake_app/models/opportunity.dart';
import 'package:salesquake_app/services/opportunity_service.dart';
import 'package:salesquake_app/controllers/navigation_controller.dart';
import 'package:salesquake_app/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class OpportunitiesWayPointListScreen extends StatefulWidget {
  final NavigationController? navigationController;
  final Function(List<LatLng>)? onWaypointsSelected; // Add this callback
  final bool isWaypointSelection; // Add this flag

  const OpportunitiesWayPointListScreen({
    Key? key,
    this.navigationController,
    this.onWaypointsSelected,
    this.isWaypointSelection = false, // Default to false for backward compatibility
  }) : super(key: key);

  @override
  State<OpportunitiesWayPointListScreen> createState() => _OpportunitiesWayPointListScreenState();
}

class _OpportunitiesWayPointListScreenState extends State<OpportunitiesWayPointListScreen> {
  List<Opportunity> _opportunities = [];
  List<Opportunity> _filteredOpportunities = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<Opportunity> _selectedOpportunities = [];

  @override
  void initState() {
    super.initState();

    // Register the refresh callback with the navigation controller
    if (widget.navigationController != null) {
      widget.navigationController!.setOpportunitiesRefreshCallback(refreshOpportunities);
    }

    _loadOpportunities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Public method to refresh opportunities from external calls
  void refreshOpportunities() {
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiResponse = await OpportunityService.getOpportunities();

      setState(() {
        if (apiResponse.data != null) {
          _opportunities = apiResponse.data!;
          _filteredOpportunities = apiResponse.data!;
          _errorMessage = null;
        } else {
          _opportunities = [];
          _filteredOpportunities = [];
          _errorMessage = apiResponse.message;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
        _opportunities = [];
        _filteredOpportunities = [];
      });
    }
  }

  void _filterOpportunities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOpportunities = _opportunities;
      } else {
        _filteredOpportunities = _opportunities.where((opportunity) => opportunity.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  void _handleOpportunitySelection(Opportunity opportunity) {
    setState(() {
      if (_selectedOpportunities.contains(opportunity)) {
        _selectedOpportunities.remove(opportunity);
      } else {
        _selectedOpportunities.add(opportunity);
      }
    });
  }

  LatLng? _getOpportunityLocation(Opportunity opportunity) {
    // Check if opportunity has location override
    if (opportunity.locationOverride != null && opportunity.locationOverride!.length >= 2) {
      return LatLng(opportunity.locationOverride![0], opportunity.locationOverride![1]);
    }

    // Check if company has location (GeoPoint is a List<double>)
    if (opportunity.company.location != null && opportunity.company.location!.length >= 2) {
      return LatLng(opportunity.company.location![0], opportunity.company.location![1]);
    }

    return null; // No location available
  }

  void _confirmSelection() {
    List<LatLng> selectedLocations = [];

    for (var opportunity in _selectedOpportunities) {
      final location = _getOpportunityLocation(opportunity);
      if (location != null) {
        selectedLocations.add(location);
      }
    }

    if (selectedLocations.isNotEmpty) {
      if (widget.onWaypointsSelected != null) {
        widget.onWaypointsSelected!(selectedLocations);
      }
      Navigator.pop(context, selectedLocations);
    } else {
      // Show message that no valid locations were found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected opportunities do not have valid locations'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isWaypointSelection
          ? AppBar(
              title: Text('Select Waypoints'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              actions: [
                if (_selectedOpportunities.isNotEmpty)
                  TextButton(
                    onPressed: _confirmSelection,
                    child: Text('Add (${_selectedOpportunities.length})'),
                  ),
              ],
            )
          : null,
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
              'Error loading opportunities',
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
              onPressed: _loadOpportunities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredOpportunities.isEmpty && _opportunities.isNotEmpty) {
      return Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterOpportunities,
              decoration: InputDecoration(
                hintText: 'Search opportunities...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterOpportunities('');
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
                    'No opportunities match your search',
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

    if (_opportunities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No opportunities found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: _filterOpportunities,
                decoration: InputDecoration(
                  hintText: 'Search opportunities...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _filterOpportunities('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              onRefresh: _loadOpportunities,
              color: Colors.blue,
              backgroundColor: Colors.white,
              child: ListView.builder(
                itemCount: _filteredOpportunities.length,
                itemBuilder: (context, index) {
                  final opportunity = _filteredOpportunities[index];
                  return _buildOpportunityCard(opportunity);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Opportunity opportunity) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    final bool isSelected = _selectedOpportunities.contains(opportunity);

    return InkWell(
      onTap: () {
        if (widget.isWaypointSelection) {
          // Handle waypoint selection
          _handleOpportunitySelection(opportunity);
        } else {
          // Original navigation behavior
          Navigator.pushNamed(
            context,
            AppRoutes.opportunityDetail,
            arguments: opportunity.id,
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: isSelected ? Colors.blue[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.blue : Color(0xFFC5C6CC),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with opportunity name and status
              Row(
                children: [
                  // Opportunity avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                opportunity.company.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
