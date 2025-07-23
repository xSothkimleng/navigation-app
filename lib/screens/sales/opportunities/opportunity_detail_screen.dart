import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/opportunity.dart';
import '../../../services/opportunity_service.dart';
import '../../../models/api_response.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final String opportunityId;

  const OpportunityDetailScreen({
    Key? key,
    required this.opportunityId,
  }) : super(key: key);

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  Opportunity? _opportunity;
  bool _isLoading = true;
  String? _errorMessage;
  List<StageInfo> _stages = [];
  bool _isUpdatingStage = false;

  @override
  void initState() {
    super.initState();
    _loadOpportunity();
    _loadStages();
  }

  Future<void> _loadOpportunity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ApiResponse<Opportunity> response =
          await OpportunityService.getOpportunityById(widget.opportunityId);

      if (response.data != null) {
        setState(() {
          _opportunity = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load opportunity';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading opportunity: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStages() async {
    try {
      final apiResponse = await OpportunityService.getStages();
      if (apiResponse.data != null && mounted) {
        setState(() {
          _stages = apiResponse.data!;
        });
        print('Loaded ${_stages.length} stages successfully');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiResponse.message ?? 'Failed to load stages'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _loadStages,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading stages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading stages: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadStages,
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateStage(String stageId) async {
    if (_opportunity == null) return;

    setState(() {
      _isUpdatingStage = true;
    });

    try {
      final apiResponse = await OpportunityService.updateOpportunityStage(
        _opportunity!.id,
        stageId,
      );

      if (apiResponse.data != null) {
        setState(() {
          _opportunity = apiResponse.data;
          _isUpdatingStage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiResponse.message ?? 'Stage updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isUpdatingStage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiResponse.message ?? 'Failed to update stage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdatingStage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating stage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStageUpdateBottomSheet() {
    // Load stages if they haven't been loaded yet
    if (_stages.isEmpty) {
      _loadStages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading stages...'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    String? selectedStageId = _opportunity?.stage.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.timeline,
                          size: 18,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Update Stage',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Select a new stage for this opportunity:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stage dropdown
                  SizedBox(
                    height: 50,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.white, // White dropdown background
                        inputDecorationTheme: InputDecorationTheme(
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle:
                              const TextStyle(color: Colors.blue),
                          prefixIconColor: MaterialStateColor.resolveWith(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused)) {
                                return Colors.blue;
                              }
                              return Colors.grey;
                            },
                          ),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedStageId,
                        decoration: InputDecoration(
                          labelText: 'Stage',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.timeline, size: 20),
                          fillColor: Colors.white,
                          filled: true,
                          floatingLabelStyle: TextStyle(
                            color: selectedStageId != null
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        hint: const Text('Select a stage'),
                        items: _stages.map((stage) {
                          return DropdownMenuItem<String>(
                            value: stage.id,
                            child: Text('${stage.name} (${stage.percentage}%)'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setSheetState(() {
                            selectedStageId = newValue;
                          });
                        },
                        isExpanded: true,
                        dropdownColor:
                            Colors.white, // White dropdown menu background
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: selectedStageId != null &&
                                  selectedStageId != _opportunity?.stage.id
                              ? () {
                                  Navigator.of(context).pop();
                                  _updateStage(selectedStageId!);
                                }
                              : null,
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top header matching main app layout style
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
                  // Left side - Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Page title (centered)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Opportunity Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // Right side - Edit button
                  if (_opportunity != null)
                    IconButton(
                      icon: _isUpdatingStage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black87),
                              ),
                            )
                          : const Icon(Icons.edit, color: Colors.black87),
                      onPressed:
                          _isUpdatingStage ? null : _showStageUpdateBottomSheet,
                      tooltip: 'Update Stage',
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
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
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOpportunity,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_opportunity == null) {
      return const Center(
        child: Text('No opportunity data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainCard(),
          const SizedBox(height: 16),
          _buildActivitiesCard(),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFC5C6CC),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with opportunity name and status
            Row(
              children: [
                // Opportunity avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.business_center,
                    color: Colors.green[600],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _opportunity!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                              _opportunity!.company.name,
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

            const SizedBox(height: 20),

            // Amount and Stage
            _buildInfoRow(
              Icons.attach_money,
              currencyFormatter.format(_opportunity!.amount),
            ),

            _buildInfoRow(
              Icons.timeline,
              '${_opportunity!.stage.name} (${_opportunity!.stage.percentage}%)',
            ),

            // Contact
            _buildInfoRow(
              Icons.person_outlined,
              '${_opportunity!.contact.firstName} ${_opportunity!.contact.lastName}',
            ),

            // Territory
            if (_opportunity!.territory.name.isNotEmpty)
              _buildInfoRow(
                Icons.place_outlined,
                _opportunity!.territory.name,
                label: 'Territory',
              ),

            // Estimate close date
            if (_opportunity!.estimateCloseDate != null)
              _buildInfoRow(
                Icons.calendar_today_outlined,
                DateFormat('MMM dd, yyyy')
                    .format(_opportunity!.estimateCloseDate!),
                label: 'Estimate Close Date',
              ),

            // Actual close date
            if (_opportunity!.actualCloseDate != null)
              _buildInfoRow(
                Icons.event_available_outlined,
                DateFormat('MMM dd, yyyy')
                    .format(_opportunity!.actualCloseDate!),
                label: 'Actual Close Date',
              ),

            // Location Override
            if (_opportunity!.locationOverride != null)
              _buildLocationRow(
                Icons.location_on_outlined,
                _opportunity!.locationOverride![0],
                _opportunity!.locationOverride![1],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {bool isUrl = false,
      String? label,
      bool isEditable = false,
      VoidCallback? onTap}) {
    Widget content = Padding(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null) ...[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Row(
                    children: [
                      Expanded(
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
                      if (isEditable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (isEditable && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
  }

  Widget _buildLocationRow(IconData icon, double latitude, double longitude) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Latitude: ${latitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Longitude: ${longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        // Sample activity items
        _buildActivityItem(
          'John',
          'created',
          'Email',
          '7/22/2025, 12:00:13 PM',
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean elementum mauris ex, vel sollicitudin ligula molestie sed. Mauris nec quam vehicula, finibus lorem eu, vestibulum turpis. Nulla mattis vehicula molestie...',
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          'Jack',
          'created',
          'Call',
          '7/22/2025, 12:00:13 PM',
          'Vivamus rhoncus feugiat libero at viverra. Integer at sapien quam. Proin tincidunt bibendum ultrices. Integer quam leo, commodo sit amet imperdiet a, congue quis est...',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String userName,
    String action,
    String activityType,
    String timestamp,
    String description,
    Color avatarColor,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFC5C6CC),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and timestamp
            Row(
              children: [
                // User avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            action,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: avatarColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              activityType,
                              style: TextStyle(
                                fontSize: 12,
                                color: avatarColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Activity description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
