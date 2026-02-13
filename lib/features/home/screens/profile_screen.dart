// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/features/auth/providers/profile_provider.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final List<String> _genderOptions = const ['Male', 'Female', 'Other'];

  Future<void> _pickAndUploadImage(BuildContext context, ProfileProvider provider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;
    await provider.uploadImage(File(image.path));
  }

  Future<void> _saveProfile(BuildContext context, ProfileProvider profileProvider, AuthProvider authProvider) async {
    final success = await profileProvider.saveProfile(authProvider);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!profileProvider.isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => profileProvider.setEditing(true)),
          if (profileProvider.isEditing)
            IconButton(icon: const Icon(Icons.save), onPressed: () => _saveProfile(context, profileProvider, authProvider)),
          if (profileProvider.isEditing)
            IconButton(icon: const Icon(Icons.close), onPressed: () => profileProvider.setEditing(false)),
        ],
      ),
      body: profileProvider.isLoading && profileProvider.employeeIdController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: profileProvider.profileImageUrl != null
                                ? NetworkImage(profileProvider.profileImageUrl!)
                                : null,
                            child: profileProvider.profileImageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          if (profileProvider.isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _pickAndUploadImage(context, profileProvider),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF26A69A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    CustomTextField(
                      controller: profileProvider.nameController,
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      onChanged: (_) => profileProvider.onFieldChanged(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                      readOnly: !profileProvider.isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextField(
                      controller: profileProvider.emailController,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      onChanged: (_) => profileProvider.onFieldChanged(),
                      readOnly: !profileProvider.isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Mobile Field
                    CustomTextField(
                      controller: profileProvider.mobileController,
                      labelText: 'Mobile Number',
                      prefixIcon: const Icon(Icons.phone),
                      maxLength: 10,
                      onChanged: (_) => profileProvider.onFieldChanged(),
                      readOnly: !profileProvider.isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Alternate Mobile Field
                    CustomTextField(
                      controller: profileProvider.alterMobileController,
                      labelText: 'Alternate Mobile Number',
                      prefixIcon: const Icon(Icons.phone_android),
                      maxLength: 10,
                      onChanged: (_) => profileProvider.onFieldChanged(),
                      readOnly: !profileProvider.isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Gender Field
                    profileProvider.isEditing
                        ? DropdownButtonFormField<String>(
                            value: _genderOptions.contains(profileProvider.genderController.text)
                                ? profileProvider.genderController.text
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              prefixIcon: const Icon(Icons.transgender),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: _genderOptions
                                .map(
                                  (gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              profileProvider.genderController.text = value ?? '';
                              profileProvider.onFieldChanged();
                            },
                          )
                        : CustomTextField(
                            controller: profileProvider.genderController,
                            labelText: 'Gender',
                            prefixIcon: const Icon(Icons.transgender),
                            readOnly: true,
                          ),
                    const SizedBox(height: 16),

                    // Address Field
                    CustomTextField(
                      controller: profileProvider.addressController,
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.home),
                      maxLines: 5,
                      onChanged: (_) => profileProvider.onFieldChanged(),
                      readOnly: !profileProvider.isEditing,
                    ),
                    const SizedBox(height: 24),

                    // Employee ID Field
                    CustomTextField(
                      controller: profileProvider.employeeIdController,
                      labelText: 'Employee ID',
                      prefixIcon: const Icon(Icons.badge),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
