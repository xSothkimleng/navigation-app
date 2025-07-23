import 'package:flutter/material.dart';
import 'package:salesquake_app/models/company.dart';
import 'package:salesquake_app/models/contact.dart';
import 'package:salesquake_app/models/country.dart';
import 'package:salesquake_app/services/company_service.dart';
import 'package:salesquake_app/services/contact_service.dart';
import 'package:salesquake_app/services/country_service.dart';

class CreateContactScreen extends StatefulWidget {
  final VoidCallback? onContactCreated;

  const CreateContactScreen({Key? key, this.onContactCreated})
      : super(key: key);

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final bool _isActive = true;
  bool _isLoading = false;

  // Country selection
  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;

  // Company selection
  List<Company> _companies = [];
  Company? _selectedCompany;
  bool _isLoadingCompanies = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _loadCompanies();
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get company ID from selected company
      String? companyId = _selectedCompany?.id;

      final contactInput = ContactInput(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        isActive: _isActive,
        countryId: _selectedCountry?.id,
        companyId: companyId != null ? int.tryParse(companyId) : null,
      );

      final response = await ContactService.createContact(contactInput);

      if (response.data != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Call the callback to refresh the contacts list
        if (widget.onContactCreated != null) {
          widget.onContactCreated!();
        }

        // Navigate back to contacts list using proper navigation
        Navigator.pop(context, true); // Return true to indicate success
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to create contact'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
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
                        'Create Contact',
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
                      // First Name (Required)
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person, size: 20),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Last Name (Required)
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Email
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email, size: 20),
                            hintText: 'example@email.com',
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Phone
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone, size: 20),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Country Selection
                      _isLoadingCountries
                          ? const SizedBox(
                              height: 50,
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
                              child: SizedBox(
                                height: 50,
                                child: DropdownButtonFormField<Country>(
                                  value: _selectedCountry,
                                  decoration: InputDecoration(
                                    labelText: 'Country',
                                    border: const OutlineInputBorder(),
                                    prefixIcon:
                                        const Icon(Icons.public, size: 20),
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
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
                                        child: Text(country.name),
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
                            ),
                      const SizedBox(height: 12),

                      // Company Selection
                      _isLoadingCompanies
                          ? const SizedBox(
                              height: 50,
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
                              child: SizedBox(
                                height: 50,
                                child: DropdownButtonFormField<Company>(
                                  value: _selectedCompany,
                                  decoration: InputDecoration(
                                    labelText: 'Company',
                                    border: const OutlineInputBorder(),
                                    prefixIcon:
                                        const Icon(Icons.business, size: 20),
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    floatingLabelStyle: TextStyle(
                                      color: _selectedCompany != null
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  hint: const Text('Select a company'),
                                  items: [
                                    // Add a "None" option to clear selection
                                    const DropdownMenuItem<Company>(
                                      value: null,
                                      child: Text(
                                        'None',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    // Add all companies
                                    ..._companies.map((Company company) {
                                      return DropdownMenuItem<Company>(
                                        value: company,
                                        child: Text(company.name),
                                      );
                                    }),
                                  ],
                                  onChanged: (Company? newValue) {
                                    setState(() {
                                      _selectedCompany = newValue;
                                    });
                                  },
                                  isExpanded: true,
                                  dropdownColor: Colors
                                      .white, // White dropdown menu background
                                ),
                              ),
                            ),

                      const SizedBox(height: 20),

                      // Save Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveContact,
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
                                  'Create Contact',
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
