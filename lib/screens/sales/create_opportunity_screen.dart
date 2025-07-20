import 'package:flutter/material.dart';
import 'package:salesquake_app/models/opportunity.dart';
import 'package:salesquake_app/models/company.dart';
import 'package:salesquake_app/models/contact.dart';
import 'package:salesquake_app/models/geometry.dart';
import 'package:salesquake_app/services/opportunity_service.dart';
import 'package:salesquake_app/services/territory_service.dart';
import 'package:salesquake_app/services/company_service.dart';
import 'package:salesquake_app/services/contact_service.dart';
import 'package:intl/intl.dart';

class CreateOpportunityScreen extends StatefulWidget {
  final VoidCallback? onOpportunityCreated;

  const CreateOpportunityScreen({Key? key, this.onOpportunityCreated})
      : super(key: key);

  @override
  State<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final bool _isActive = true;
  bool _isLoading = false;

  // Dropdown selections
  List<StageInfo> _stages = [];
  List<TerritoryInfo> _territories = [];
  List<Company> _companies = [];
  List<Contact> _contacts = [];

  StageInfo? _selectedStage;
  TerritoryInfo? _selectedTerritory;
  Company? _selectedCompany;
  Contact? _selectedContact;
  DateTime? _selectedEstimatedCloseDate;
  DateTime? _selectedActualCloseDate;

  bool _isLoadingStages = true;
  bool _isLoadingTerritories = true;
  bool _isLoadingCompanies = true;
  bool _isLoadingContacts = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadStages(),
      _loadTerritories(),
      _loadCompanies(),
      _loadContacts(),
    ]);
  }

  Future<void> _loadStages() async {
    try {
      final response = await OpportunityService.getStages();
      if (response.data != null && mounted) {
        setState(() {
          _stages = response.data!;
          _isLoadingStages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stages: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadTerritories() async {
    try {
      final response = await TerritoryService.getTerritories();
      if (response.data != null && mounted) {
        setState(() {
          _territories = response.data!;
          _isLoadingTerritories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTerritories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load territories: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadCompanies() async {
    try {
      final response = await CompanyService.getCompanies();
      if (response.data != null && mounted) {
        setState(() {
          _companies = response.data!;
          _isLoadingCompanies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompanies = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load companies: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadContacts() async {
    try {
      final response = await ContactService.getContacts();
      if (response.data != null && mounted) {
        setState(() {
          _contacts = response.data!;
          _isLoadingContacts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingContacts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load contacts: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveOpportunity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse location if both lat and long are provided
      GeoPoint? location;
      final latText = _latitudeController.text.trim();
      final lngText = _longitudeController.text.trim();

      if (latText.isNotEmpty || lngText.isNotEmpty) {
        if (latText.isEmpty || lngText.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Both latitude and longitude must be provided together'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        try {
          final lat = double.parse(latText);
          final lng = double.parse(lngText);

          if (lat < -90 || lat > 90) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Latitude must be between -90 and 90'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          if (lng < -180 || lng > 180) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Longitude must be between -180 and 180'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          location = [lat, lng];
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid latitude or longitude format'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final opportunityInput = OpportunityInput(
        name: _nameController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()),
        stageId: _selectedStage?.id,
        companyId: _selectedCompany?.id,
        contactId: _selectedContact?.id,
        territoryId: _selectedTerritory?.id,
        isActive: _isActive,
        locationOverride:
            location != null ? GeoLocation.fromGeoPoint(location) : null,
        estimatedCloseDate: _selectedEstimatedCloseDate,
        actualCloseDate: _selectedActualCloseDate,
      );

      final response =
          await OpportunityService.createOpportunity(opportunityInput);

      if (response.data != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opportunity created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.onOpportunityCreated != null) {
          widget.onOpportunityCreated!();
        }

        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to create opportunity'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                        'Create Opportunity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // Right side - Balance space
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 24, top: 24, right: 24),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: Colors.blue,
                        ),
                    inputDecorationTheme: InputDecorationTheme(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      labelStyle: const TextStyle(color: Colors.grey),
                      floatingLabelStyle: const TextStyle(color: Colors.blue),
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
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        // Opportunity Name (Required)
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Opportunity Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business_center),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Opportunity name is required';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),

                        // Amount (Required)
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Amount is required';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Stage Selection
                        _isLoadingStages
                            ? const SizedBox(
                                height: 56,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor:
                                      Colors.white, // White dropdown background
                                  inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    floatingLabelStyle: const TextStyle(
                                        color:
                                            Colors.blue), // Blue when selected
                                    prefixIconColor:
                                        MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.focused)) {
                                          return Colors.blue;
                                        }
                                        return Colors.grey;
                                      },
                                    ),
                                  ),
                                ),
                                child: DropdownButtonFormField<StageInfo>(
                                  value: _selectedStage,
                                  decoration: InputDecoration(
                                    labelText: 'Stage',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.timeline),
                                    fillColor: Colors.white,
                                    filled: true,
                                    floatingLabelStyle: TextStyle(
                                      color: _selectedStage != null
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  hint: const Text('Select a stage'),
                                  items: _stages.map((StageInfo stage) {
                                    return DropdownMenuItem<StageInfo>(
                                      value: stage,
                                      child: Text(
                                          '${stage.name} (${stage.percentage}%)'),
                                    );
                                  }).toList(),
                                  onChanged: (StageInfo? newValue) {
                                    setState(() {
                                      _selectedStage = newValue;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a stage'
                                      : null,
                                  isExpanded: true,
                                  dropdownColor: Colors
                                      .white, // White dropdown menu background
                                ),
                              ),
                        const SizedBox(height: 16),

                        // Company Selection
                        _isLoadingCompanies
                            ? const SizedBox(
                                height: 56,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor:
                                      Colors.white, // White dropdown background
                                  inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    floatingLabelStyle: const TextStyle(
                                        color:
                                            Colors.blue), // Blue when selected
                                    prefixIconColor:
                                        MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.focused)) {
                                          return Colors.blue;
                                        }
                                        return Colors.grey;
                                      },
                                    ),
                                  ),
                                ),
                                child: DropdownButtonFormField<Company>(
                                  value: _selectedCompany,
                                  decoration: InputDecoration(
                                    labelText: 'Company',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.business),
                                    fillColor: Colors.white,
                                    filled: true,
                                    floatingLabelStyle: TextStyle(
                                      color: _selectedCompany != null
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  hint: const Text('Select a company'),
                                  items: _companies.map((Company company) {
                                    return DropdownMenuItem<Company>(
                                      value: company,
                                      child: Text(company.name),
                                    );
                                  }).toList(),
                                  onChanged: (Company? newValue) {
                                    setState(() {
                                      _selectedCompany = newValue;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a company'
                                      : null,
                                  isExpanded: true,
                                  dropdownColor: Colors
                                      .white, // White dropdown menu background
                                ),
                              ),
                        const SizedBox(height: 16),

                        // Contact Selection
                        _isLoadingContacts
                            ? const SizedBox(
                                height: 56,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor:
                                      Colors.white, // White dropdown background
                                  inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    floatingLabelStyle: const TextStyle(
                                        color:
                                            Colors.blue), // Blue when selected
                                    prefixIconColor:
                                        MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.focused)) {
                                          return Colors.blue;
                                        }
                                        return Colors.grey;
                                      },
                                    ),
                                  ),
                                ),
                                child: DropdownButtonFormField<Contact>(
                                  value: _selectedContact,
                                  decoration: InputDecoration(
                                    labelText: 'Contact',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.person),
                                    fillColor: Colors.white,
                                    filled: true,
                                    floatingLabelStyle: TextStyle(
                                      color: _selectedContact != null
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  hint: const Text('Select a contact'),
                                  items: _contacts.map((Contact contact) {
                                    return DropdownMenuItem<Contact>(
                                      value: contact,
                                      child: Text(
                                          '${contact.firstName} ${contact.lastName}'),
                                    );
                                  }).toList(),
                                  onChanged: (Contact? newValue) {
                                    setState(() {
                                      _selectedContact = newValue;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a contact'
                                      : null,
                                  isExpanded: true,
                                  dropdownColor: Colors
                                      .white, // White dropdown menu background
                                ),
                              ),
                        const SizedBox(height: 16),

                        // Territory Selection
                        _isLoadingTerritories
                            ? const SizedBox(
                                height: 56,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor:
                                      Colors.white, // White dropdown background
                                  inputDecorationTheme: InputDecorationTheme(
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.blue, width: 2.0),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    floatingLabelStyle: const TextStyle(
                                        color:
                                            Colors.blue), // Blue when selected
                                    prefixIconColor:
                                        MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.focused)) {
                                          return Colors.blue;
                                        }
                                        return Colors.grey;
                                      },
                                    ),
                                  ),
                                ),
                                child: DropdownButtonFormField<TerritoryInfo>(
                                  value: _selectedTerritory,
                                  decoration: InputDecoration(
                                    labelText: 'Territory',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.map),
                                    fillColor: Colors.white,
                                    filled: true,
                                    floatingLabelStyle: TextStyle(
                                      color: _selectedTerritory != null
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  hint: const Text('Select a territory'),
                                  items: _territories
                                      .map((TerritoryInfo territory) {
                                    return DropdownMenuItem<TerritoryInfo>(
                                      value: territory,
                                      child: Text(territory.name),
                                    );
                                  }).toList(),
                                  onChanged: (TerritoryInfo? newValue) {
                                    setState(() {
                                      _selectedTerritory = newValue;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a territory'
                                      : null,
                                  isExpanded: true,
                                  dropdownColor: Colors
                                      .white, // White dropdown menu background
                                ),
                              ),
                        const SizedBox(height: 16),

                        // Estimated Close Date
                        InkWell(
                          onTap: () => _selectDate(),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Estimated Close Date',
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              labelStyle: const TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(
                                color: _selectedEstimatedCloseDate != null
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: _selectedEstimatedCloseDate != null
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                            child: Text(
                              _selectedEstimatedCloseDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(_selectedEstimatedCloseDate!)
                                  : 'Select date (optional)',
                              style: TextStyle(
                                color: _selectedEstimatedCloseDate != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Actual Close Date
                        InkWell(
                          onTap: () => _selectActualDate(),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Actual Close Date',
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              labelStyle: const TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(
                                color: _selectedActualCloseDate != null
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              prefixIcon: Icon(
                                Icons.event_available,
                                color: _selectedActualCloseDate != null
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                            child: Text(
                              _selectedActualCloseDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(_selectedActualCloseDate!)
                                  : 'Select date (optional)',
                              style: TextStyle(
                                color: _selectedActualCloseDate != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location Override Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                const Text(
                                  'Location Override (Optional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Latitude
                            TextFormField(
                              controller: _latitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.swap_vert),
                                hintText: '37.7749',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final lat = double.tryParse(value.trim());
                                  if (lat == null) {
                                    return 'Invalid latitude';
                                  }
                                  if (lat < -90 || lat > 90) {
                                    return 'Latitude must be between -90 and 90';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Longitude
                            TextFormField(
                              controller: _longitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.swap_horiz),
                                hintText: '-122.4194',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final lng = double.tryParse(value.trim());
                                  if (lng == null) {
                                    return 'Invalid longitude';
                                  }
                                  if (lng < -180 || lng > 180) {
                                    return 'Longitude must be between -180 and 180';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveOpportunity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Create Opportunity',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEstimatedCloseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.blue, // Header background color
                  onPrimary: Colors.white, // Header text color
                  surface: Colors.white, // Calendar background
                  onSurface: Colors.black87, // Calendar text color
                ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedEstimatedCloseDate) {
      setState(() {
        _selectedEstimatedCloseDate = picked;
      });
    }
  }

  Future<void> _selectActualDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedActualCloseDate ?? DateTime.now(),
      firstDate: DateTime(2020), // Allow past dates for actual close date
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.blue, // Header background color
                  onPrimary: Colors.white, // Header text color
                  surface: Colors.white, // Calendar background
                  onSurface: Colors.black87, // Calendar text color
                ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedActualCloseDate) {
      setState(() {
        _selectedActualCloseDate = picked;
      });
    }
  }
}
