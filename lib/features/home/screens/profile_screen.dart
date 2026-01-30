// ignore_for_file: use_build_context_s, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/core/services/secure_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _alterMobileController;
  late TextEditingController _genderController;
  late TextEditingController _addressController;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _alterMobileController = TextEditingController();
    _genderController = TextEditingController();
    _addressController = TextEditingController();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _alterMobileController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final secureStorage = SecureStorageService();

    // Fetch profile data from provider or secure storage
    if (authProvider.profileData == null) {
      final employeeId = await secureStorage.getEmployeeId() ?? '';
      if (employeeId.isNotEmpty) {
        await authProvider.fetchAndCacheProfileData(employeeId: employeeId);
      }
    }

    // Load data into controllers
    final profileData = authProvider.profileData;
    final userData = await secureStorage.getUserData();

    setState(() {
      _nameController.text = userData?['username'] ?? '';
      _emailController.text = userData?['email'] ?? '';
      _mobileController.text = profileData?.mobile ?? '';
      _alterMobileController.text = profileData?.alterMobile ?? '';
      _genderController.text = profileData?.gender ?? '';
      _addressController.text = profileData?.address ?? '';
    });
  }

  Future<void> _toggleEdit() async {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final secureStorage = SecureStorageService();
      final employeeId = await secureStorage.getEmployeeId() ?? '';

      final success = await authProvider.updateProfileData(
        employeeId: employeeId,
        name: _nameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        alterMobile: _alterMobileController.text,
        gender: _genderController.text,
        address: _addressController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to update profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while updating profile'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileData = authProvider.profileData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('My Profile',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: _toggleEdit),
          if (_isEditing)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
          if (_isEditing)
            IconButton(icon: const Icon(Icons.close), onPressed: _toggleEdit),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: profileData?.profileImage != null
                            ? NetworkImage(profileData!.profileImage!)
                            : null,
                        child: profileData?.profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Mobile Field
                    CustomTextField(
                      controller: _mobileController,
                      labelText: 'Mobile Number',

                      prefixIcon: const Icon(Icons.phone),
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        if (value.length != 10) {
                          return 'Mobile number must be 10 digits';
                        }
                        return null;
                      },
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Alternate Mobile Field
                    CustomTextField(
                      controller: _alterMobileController,
                      labelText: 'Alternate Mobile Number',
                      prefixIcon: const Icon(Icons.phone_android),
                      maxLength: 10,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length != 10) {
                          return 'Mobile number must be 10 digits';
                        }
                        return null;
                      },
                      readOnly: !_isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Gender Field
                    _isEditing
                        ? DropdownButtonFormField<String>(
                            value: _genderOptions.contains(_genderController.text)
                                ? _genderController.text
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: const Icon(Icons.transgender),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                            items: _genderOptions
                                .map((gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _genderController.text = value ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                          )
                        : CustomTextField(
                            controller: _genderController,
                            labelText: 'Gender',
                            prefixIcon: const Icon(Icons.transgender),
                            readOnly: true,
                          ),
                    const SizedBox(height: 16),

                    // Address Field
                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.home),
                      maxLines: 5,
                      readOnly: !_isEditing,
                    ),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        final TextEditingController employeeIdController =
                            TextEditingController();
                        SecureStorageService().getEmployeeId().then((
                          employeeId,
                        ) {
                          if (employeeId != null) {
                            employeeIdController.text = employeeId;
                          }
                        });

                        return CustomTextField(
                          controller: employeeIdController,
                          labelText: 'Employee ID',
                          prefixIcon: const Icon(Icons.badge),
                          readOnly: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
