import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/storage_service.dart';
import '../../services/health_check_service.dart';
import '../../utils/constants.dart';

class InstanceConfigScreen extends StatefulWidget {
  final VoidCallback? onConfigurationComplete;

  const InstanceConfigScreen({Key? key, this.onConfigurationComplete})
      : super(key: key);

  @override
  State<InstanceConfigScreen> createState() => _InstanceConfigScreenState();
}

class _InstanceConfigScreenState extends State<InstanceConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _portController = TextEditingController();
  final _urlFocusNode = FocusNode();
  final _portFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isTestingConnection = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingConfiguration();
  }

  Future<void> _loadExistingConfiguration() async {
    try {
      final savedUrl = await StorageService.getApiUrl();
      final savedPort = await StorageService.getApiPort();

      if (savedUrl != null) {
        _urlController.text = savedUrl;
      }
      if (savedPort != null) {
        _portController.text = savedPort;
      }
    } catch (e) {
      print('Error loading existing configuration: $e');
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final url = _urlController.text.trim();
      final port = _portController.text.trim();

      String fullUrl = url;
      if (port.isNotEmpty) {
        fullUrl = '$url:$port';
      }

      // Validate URL format
      if (!HealthCheckService.isValidUrl(fullUrl)) {
        setState(() {
          _errorMessage =
              'Invalid URL format. Please use format like http://example.com';
          _isTestingConnection = false;
        });
        return;
      }

      // Test server connectivity
      final isHealthy = await HealthCheckService.testApiAvailability(fullUrl);

      if (isHealthy) {
        setState(() {
          _successMessage = '✅ Connection successful! Server is responding.';
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              '❌ Cannot connect to server. Please check the URL and try again.';
          _successMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection test failed: ${e.toString()}';
        _successMessage = null;
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = _urlController.text.trim();
      final port = _portController.text.trim();

      // Save configuration
      await StorageService.saveApiUrl(url);
      if (port.isNotEmpty) {
        await StorageService.saveApiPort(port);
      }

      setState(() {
        _successMessage = 'Configuration saved successfully!';
      });

      // Wait a moment to show success message
      await Future.delayed(const Duration(seconds: 1));

      // Call completion callback
      if (widget.onConfigurationComplete != null) {
        widget.onConfigurationComplete!();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save configuration: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _portController.dispose();
    _urlFocusNode.dispose();
    _portFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppConstants.primaryColor,
                    ),
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: AppConstants.primaryColor, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey[300]!, width: 1.0),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  labelStyle: const TextStyle(color: Colors.grey),
                  floatingLabelStyle:
                      const TextStyle(color: AppConstants.primaryColor),
                  prefixIconColor: MaterialStateColor.resolveWith(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.focused)) {
                        return AppConstants.primaryColor;
                      }
                      return Colors.grey;
                    },
                  ),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.cloud,
                            size: 60,
                            color: AppConstants.primaryColor,
                          );
                        },
                      ),
                    ),

                    // Title
                    const Text(
                      'Configure Instance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Enter your SalesQuake server details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // URL Field
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        controller: _urlController,
                        focusNode: _urlFocusNode,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Server URL',
                          hintText: 'http://example.com',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.cloud),
                          helperText: 'Include http:// or https://',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Server URL is required';
                          }
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          _portFocusNode.requestFocus();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Port Field (Optional)
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        controller: _portController,
                        focusNode: _portFocusNode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Port (Optional)',
                          hintText: '8080, 3000, 443, etc.',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.settings_ethernet),
                          helperText: 'Leave empty if port is included in URL',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final port = int.tryParse(value);
                            if (port == null || port < 1 || port > 65535) {
                              return 'Port must be between 1 and 65535';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Test Connection Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isTestingConnection || _isLoading
                            ? null
                            : _testConnection,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppConstants.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isTestingConnection
                            ? const SpinKitThreeBounce(
                                color: AppConstants.primaryColor,
                                size: 20,
                              )
                            : const Text(
                                'Test Connection',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Configuration Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading || _isTestingConnection
                            ? null
                            : _saveConfiguration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 20,
                              )
                            : const Text(
                                'Save Configuration',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    // Success Message
                    if (_successMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
