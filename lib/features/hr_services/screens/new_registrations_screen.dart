import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/registration_model.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/hr_services/provider/registration_provider.dart';
import 'package:provider/provider.dart';

class NewRegistrationsScreen extends StatefulWidget {
  const NewRegistrationsScreen({super.key});

  @override
  State<NewRegistrationsScreen> createState() => _NewRegistrationsScreenState();
}

class _NewRegistrationsScreenState extends State<NewRegistrationsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("New Registrations", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RegistrationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 1. Statistics Row - Consumes state from Provider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: "People", count: provider.totalPeople.toString()),
                    _StatItem(label: "Departments", count: provider.totalDepartments.toString()),
                  ],
                ),
              ),

              // 2. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.updateSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. Filters - Consumes unique dynamic options from Provider
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterDropdown(
                      label: "Departments",
                      currentValue: provider.selectedDepartment,
                      options: provider.uniqueDepartments,
                      onChanged: (val) => provider.updateDepartmentFilter(val),
                    ),
                    const SizedBox(width: 8),
                    _FilterDropdown(
                      label: "Positions",
                      currentValue: provider.selectedPosition,
                      options: provider.uniquePositions,
                      onChanged: (val) => provider.updatePositionFilter(val),
                    ),
                    const SizedBox(width: 8),
                    _FilterDropdown(
                      label: "Status",
                      currentValue: provider.selectedStatus,
                      options: provider.uniqueStatuses,
                      onChanged: (val) => provider.updateStatusFilter(val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. List Area - Reacts to loading/loaded states
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchRegistrations(), // Silent refresh in background
                  child: _buildListContent(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListContent(RegistrationProvider provider) {
    if (provider.state == RegistrationState.loading && provider.registrations.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
    }

    if (provider.registrations.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/no_data.png",
                height: 200,
                errorBuilder: (c, e, s) => const Icon(Icons.inbox, size: 80, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text("No new registrations found", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.registrations.length,
      itemBuilder: (context, index) {
        return _RegistrationCard(registration: provider.registrations[index]);
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String count;
  const _StatItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String currentValue;
  final List<String> options;
  final Function(String) onChanged;
  
  const _FilterDropdown({
    required this.label, 
    required this.currentValue,
    required this.options,
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterSheet(context, label, options, currentValue, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(currentValue == 'All' ? label : currentValue, 
                style: const TextStyle(fontSize: 12)),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, String title, List<String> options, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final opt = options[index];
                        return _FilterOption(
                          label: opt, 
                          isSelected: opt == current, 
                          onTap: () {
                            onSelect(opt);
                            Navigator.pop(context);
                          }
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 18)),
      trailing: Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : Colors.grey),
      onTap: onTap,
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final RegistrationModel registration;
  const _RegistrationCard({required this.registration});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(registration.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text(registration.position, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showApprovalConfirmation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A69A),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Approve", style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue, size: 20),
                      onPressed: () => _showUserDetails(context),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                      onPressed: () => _showHoldActionDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(registration.email, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Phone", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(registration.phone, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Department", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(registration.department, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Joined", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(registration.appliedOn, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHoldActionDialog(BuildContext context) {
    final provider = context.read<RegistrationProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF26A69A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Hold Action", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Choose an action for this user:", style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final success = await provider.rejectUser(registration.email);
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                AlertHelper.snackBarSuccess(context, "User rejected successfully");
                              } else {
                                AlertHelper.snackBarError(context, "Failed to reject user");
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Reject", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final success = await provider.updateStatus(registration.id, "Hold");
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                AlertHelper.snackBarSuccess(context, "User put on hold");
                              } else {
                                AlertHelper.snackBarError(context, "Failed to update status");
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("On-Hold", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDetails(BuildContext context) {
    final provider = context.read<RegistrationProvider>();
    final nameController = TextEditingController(text: registration.name);
    final phoneController = TextEditingController(text: registration.phone);
    final dobController = TextEditingController(text: registration.dob);
    final deptController = TextEditingController(text: registration.department);
    final posController = TextEditingController(text: registration.position);
    final expController = TextEditingController(text: registration.experience);
    final addrController = TextEditingController(text: registration.address);
    final refController = TextEditingController(text: registration.reference);
    
    String selectedGender = registration.gender;
    String selectedStatus = registration.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF26A69A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("User Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Basic Information", style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildTextField("Name", nameController)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildTextField("Email (Not Editable)", TextEditingController(text: registration.email), enabled: false)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildTextField("Phone", phoneController)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDialogDropdown("Gender", selectedGender, ["Select", "Male", "Female"], (val) {
                                  if (val != null) setState(() => selectedGender = val);
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildTextField("DOB", dobController)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildTextField("Applied On", TextEditingController(text: registration.appliedOn), enabled: false)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text("Work Information", style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildTextField("Department", deptController)),
                              const SizedBox(width: 10),
                              Expanded(child: _buildTextField("Position", posController)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _buildTextField("Experience (Years)", expController)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDialogDropdown("Status", selectedStatus, ["Pending", "Approved", "Rejected", "Hold", "Init"], (val) {
                                  if (val != null) setState(() => selectedStatus = val);
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text("Additional Details", style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildTextField("Address", addrController, maxLines: 2),
                          const SizedBox(height: 10),
                          _buildTextField("Reference", refController),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final success = await provider.updateUserDetails(registration.email, {
                              "name": nameController.text,
                              "mobile": int.tryParse(phoneController.text) ?? phoneController.text,
                              "gender": selectedGender,
                              "DOB": dobController.text,
                              "department": deptController.text,
                              "position": posController.text,
                              "experience": expController.text,
                              "status": selectedStatus,
                              "address": addrController.text,
                              "reference": refController.text,
                            });
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                AlertHelper.snackBarSuccess(context, "User updated successfully");
                              } else {
                                AlertHelper.snackBarError(context, "Failed to update user");
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text("Update", style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showApprovalConfirmation(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                          child: const Text("Approve", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            isDense: true,
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  void _showApprovalConfirmation(BuildContext context) {
    final provider = context.read<RegistrationProvider>();
    String? selectedTeamLead;
    String? selectedPackage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF26A69A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Approval Confirmation", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Select Team Lead and Package to approve this user:", style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 20),
                        _buildDropdownSheetField(context, "Select Team Lead", ["Mukilan K", "Vignesh", "Mohd Shoaib"], (val) {
                          setState(() => selectedTeamLead = val);
                        }, selectedTeamLead),
                        const SizedBox(height: 10),
                        _buildDropdownSheetField(context, "Select Package", ["3.6 LPA", "Intern", "13 LPA"], (val) {
                          setState(() => selectedPackage = val);
                        }, selectedPackage),
                        const SizedBox(height: 20),
                        const Text("Are you sure you want to approve this user?", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedTeamLead == null || selectedPackage == null) {
                              AlertHelper.snackBarError(context, "Please select Team Lead and Package");
                              return;
                            }
                            final success = await provider.approveUser(
                              registration.email, 
                              selectedTeamLead!, 
                              selectedPackage!
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                AlertHelper.snackBarSuccess(context, "User approved successfully");
                              } else {
                                AlertHelper.snackBarError(context, "Failed to approve user");
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildDropdownSheetField(BuildContext context, String label, List<String> options, Function(String) onSelected, String? current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Divider(),
                      ...options.map((opt) => ListTile(
                        title: Text(opt, style: const TextStyle(fontSize: 18)),
                        trailing: Icon(opt == current ? Icons.radio_button_checked : Icons.radio_button_off, color: opt == current ? AppColors.primary : Colors.grey),
                        onTap: () {
                          onSelected(opt);
                          Navigator.pop(context);
                        },
                      )),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(current ?? label, style: TextStyle(fontSize: 14, color: current == null ? Colors.grey : Colors.black)),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
