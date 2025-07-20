import 'package:flutter/material.dart';
import 'package:salesquake_app/models/company.dart';
import 'package:salesquake_app/models/country.dart';
import 'package:salesquake_app/models/geometry.dart';
import 'package:salesquake_app/services/company_service.dart';
import 'package:salesquake_app/services/country_service.dart';

class CreateCompanyScreen extends StatefulWidget {
  final VoidCallback? onCompanyCreated;

  const CreateCompanyScreen({Key? key, this.onCompanyCreated})
      : super(key: key);

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final bool _isActive = true;
  bool _isLoading = false;

  // Country selection
  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final response = await CountryService.getCountries();
      if (response.data != null && mounted) {
        setState(() {
          _countries = response.data!;
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCountries = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load countries: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _postalCodeController.dispose();
    _websiteController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse location if both lat and long are provided
      GeoLocation? location;
      final latText = _latitudeController.text.trim();
      final lngText = _longitudeController.text.trim();

      if (latText.isNotEmpty || lngText.isNotEmpty) {
        // If either field has a value, both must be provided
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

          // Validate coordinate ranges
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

          location = GeoLocation(latitude: lat, longitude: lng);
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

      final companyInput = CompanyInput(
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        isActive: _isActive,
        countryId: _selectedCountry?.id,
        location: location,
      );

      final response = await CompanyService.createCompany(companyInput);

      if (response.data != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Call the callback to refresh the companies list
        if (widget.onCompanyCreated != null) {
          widget.onCompanyCreated!();
        }

        // Navigate back to companies list using proper navigation
        Navigator.pop(context, true); // Return true to indicate success
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to create company'),
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
                        'Create Company',
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
                    child:
                        ListView(padding: const EdgeInsets.all(8), children: [
                      // Company Name (Required)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Company name is required';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Postal Code
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Postal Code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Website
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.language),
                          hintText: 'https://example.com',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),

                      // Country Selection
                      _isLoadingCountries
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
                                      color: Colors.blue), // Blue when selected
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
                              child: DropdownButtonFormField<Country>(
                                value: _selectedCountry,
                                decoration: InputDecoration(
                                  labelText: 'Country',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.public),
                                  fillColor: Colors.white,
                                  filled: true,
                                  floatingLabelStyle: TextStyle(
                                    color: _selectedCountry != null
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                                hint: const Text('Select a country'),
                                items: [
                                  // Add a "None" option to clear selection
                                  const DropdownMenuItem<Country>(
                                    value: null,
                                    child: Text(
                                      'None',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  // Add all countries
                                  ..._countries.map((Country country) {
                                    return DropdownMenuItem<Country>(
                                      value: country,
                                      child: Text(country.nicename),
                                    );
                                  }),
                                ],
                                onChanged: (Country? newValue) {
                                  setState(() {
                                    _selectedCountry = newValue;
                                  });
                                },
                                isExpanded: true,
                                dropdownColor: Colors
                                    .white, // White dropdown menu background
                              ),
                            ),
                      const SizedBox(height: 16),

                      // Location Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Location Coordinates',
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                            keyboardType: const TextInputType.numberWithOptions(
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
                          onPressed: _isLoading ? null : _saveCompany,
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
                                  'Create Company',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ]), // End of ListView children
                  ), // End of Form
                ), // End of Theme
              ), // End of Container
            ), // End of Expanded
          ], // End of Column children
        ), // End of Column
      ), // End of SafeArea
    ); // End of Scaffold
  }
}
