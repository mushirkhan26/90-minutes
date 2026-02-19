import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/config/theme/app_text_styles.dart';
import 'package:hrtz_hrms/core/extensions/secure_storage_extension.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/socket/group_socket_provider.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupChatModel group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late GroupSocketProvider _groupSocketProvider;
  bool isadmin = false;
  bool _isLoading = false;
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  final List<EmployeeModel> _selectedMembers = [];
  String? _currentUserId;
  String? currentUsername;
  late GroupChatModel _group; // Local copy of the group model

  @override
  void initState() {
    super.initState();
    _groupSocketProvider = context.read<GroupSocketProvider>();
    _group = widget.group; // Initialize local copy
    _loadCurrentUserDetails();
    _loadEmployees();
    _registerSocketListeners();
  }

  @override
  void dispose() {
    _groupSocketProvider.removeListener(_onGroupUpdated);
    super.dispose();
  }

  void _registerSocketListeners() {
    _groupSocketProvider.addListener(_onGroupUpdated);
  }

  void _onGroupUpdated() {
    //  Optimization: If we are currently performing an action (loading),
    // ignore sync from provider to prevent flickering/reverting optimistic UI.
    if (_isLoading) return;

    final updatedGroup = _groupSocketProvider.groupChats.firstWhere(
      (g) => g.groupId == _group.groupId,
      orElse: () => _group,
    );

    if (updatedGroup != _group) {
      setState(() {
        _group = updatedGroup;
        _filteredEmployees = _employees
            .where((emp) => !_group.members.contains(emp.employeeID))
            .toList();
      });
    }
  }

  Future<void> _loadCurrentUserDetails() async {
    _currentUserId = await context.getCurrentEmployeeId();
    if (mounted) {
      currentUsername = await context.getCurrentUsername();
      setState(() {
        isadmin = _group.createdBy == _currentUserId;
      });
    }
  }

  Future<void> _loadEmployees() async {
    final employees = await LocalStorageService().getEmployeeList();
    if (employees != null) {
      setState(() {
        _employees = employees;
        _filteredEmployees = employees
            .where((emp) => !_group.members.contains(emp.employeeID))
            .toList();
      });
    }
  }

  // --- Helper Methods ---
  Future<void> _editGroupName() async {
    final TextEditingController nameController = TextEditingController(
      text: _group.name,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group Name'),
        content: TextField(controller: nameController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();

              if (newName.isEmpty) {
                AlertHelper.snackBarWarning(
                  context,
                  'Group name cannot be empty',
                );
                return;
              }

              // 🔥 SAVE OLD NAME (for rollback if API fails)
              final oldName = _group.name;

              // 🚀 OPTIMISTIC UI UPDATE
              setState(() {
                _isLoading = true;
                _group = _group.copyWith(name: newName);
              });

              Navigator.pop(context);

              try {
                await _groupSocketProvider.editGroupName(
                  _group.groupId,
                  newName,
                  _currentUserId ?? '',
                );

                if (mounted) {
                  AlertHelper.snackBarSuccess(context, 'Group name updated!');
                }
              } catch (e) {
                // ❌ rollback if failed
                if (mounted) {
                  setState(() {
                    _group = _group.copyWith(name: oldName);
                  });

                  AlertHelper.snackBarError(
                    context,
                    'Failed to update group name: $e',
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _addMembers() async {
    if (_currentUserId == null) {
      AlertHelper.snackBarError(context, 'User ID not found');
      return;
    }
    if (_filteredEmployees.isEmpty) {
      AlertHelper.snackBarWarning(context, 'No employees available to add');
      return;
    }
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Members'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: _filteredEmployees.length,
                itemBuilder: (context, index) {
                  final emp = _filteredEmployees[index];
                  final isSelected = _selectedMembers.contains(emp);
                  return CheckboxListTile(
                    title: Text(emp.name),
                    subtitle: Text(emp.employeeID),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedMembers.add(emp);
                        } else {
                          _selectedMembers.remove(emp);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (_selectedMembers.isEmpty) {
                    AlertHelper.snackBarWarning(
                      context,
                      'Please select at least one member',
                    );
                    return;
                  }

                  // 🚀 Optimistic UI Update
                  final previousMembers = List<String>.from(_group.members);
                  final newMemberIds = _selectedMembers
                      .map((e) => e.employeeID)
                      .toList();

                  setState(() {
                    _isLoading =
                        true; // Set loading first to block stale socket updates
                    _group = _group.copyWith(
                      members: [..._group.members, ...newMemberIds],
                    );
                    _filteredEmployees = _employees
                        .where(
                          (emp) => !_group.members.contains(emp.employeeID),
                        )
                        .toList();
                  });

                  Navigator.pop(context);

                  try {
                    await _groupSocketProvider.addGroupMembers(
                      _group.groupId,
                      newMemberIds,
                      _currentUserId!,
                    );

                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      AlertHelper.snackBarSuccess(context, 'Members added!');
                    }
                    _selectedMembers.clear();
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _group = _group.copyWith(members: previousMembers);
                        _filteredEmployees = _employees
                            .where(
                              (emp) => !_group.members.contains(emp.employeeID),
                            )
                            .toList();
                      });
                      // ignore: use_build_context_synchronously
                      AlertHelper.snackBarError(
                        context,
                        'Failed to add members: $e',
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeMember(String userId) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: const Text('This member will no longer be part of the group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
    if (shouldRemove == true) {
      // 🚀 Optimistic UI Update
      final previousMembers = List<String>.from(_group.members);
      setState(() {
        _isLoading = true; // Block stale socket updates
        _group = _group.copyWith(
          members: List<String>.from(_group.members)..remove(userId),
        );
        _filteredEmployees = _employees
            .where((emp) => !_group.members.contains(emp.employeeID))
            .toList();
      });

      try {
        await _groupSocketProvider.removeGroupMember(
          _group.groupId,
          userId,
          _currentUserId ?? '',
        );
        if (mounted) {
          AlertHelper.snackBarSuccess(context, 'Member removed!');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _group = _group.copyWith(members: previousMembers);
            _filteredEmployees = _employees
                .where((emp) => !_group.members.contains(emp.employeeID))
                .toList();
          });
          AlertHelper.snackBarError(context, 'Failed to remove member: $e');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteGroup() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text(
          'This action cannot be undone. All messages will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      try {
        setState(() => _isLoading = true);
        await _groupSocketProvider.deleteGroup(
          groupId: _group.groupId,
          deletedBy: _currentUserId ?? '',
        );
        if (!mounted) return;

        context.read<GroupSocketProvider>().fetchUserGroups();

        Navigator.popUntil(context, (route) => route.isFirst);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          AlertHelper.snackBarSuccess(context, 'Group deleted successfully');
        });
      } catch (e) {
        if (mounted) {
          AlertHelper.snackBarError(context, 'Failed to delete group: $e');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _leaveGroup() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group?'),
        content: const Text(
          'You will no longer receive messages from this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
    if (shouldLeave == true) {
      try {
        setState(() => _isLoading = true);
        await _groupSocketProvider.leaveGroup(
          groupId: _group.groupId,
          userId: _currentUserId ?? '',
        );
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          AlertHelper.snackBarSuccess(context, 'Left group successfully');
        }
      } catch (e) {
        if (mounted) {
          AlertHelper.snackBarError(context, 'Failed to leave group: $e');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  String _getEmployeeName(String employeeId) {
    try {
      final employee = _employees.firstWhere(
        (emp) => emp.employeeID == employeeId,
        orElse: () =>
            EmployeeModel(employeeID: employeeId, name: 'Unknown User'),
      );
      return employee.name;
    } catch (e) {
      return 'Unknown User';
    }
  }

  Widget _buildGroupHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: .1),
            child: ClipOval(
              child: _group.icon != null && _group.icon!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _group.icon!,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      errorWidget: (context, url, error) {
                        return const Icon(
                          Icons.group,
                          size: 30,
                          color: Colors.white,
                        );
                      },
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : const Icon(Icons.group, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_group.name, style: AppTextStyles.black18_600),
                const SizedBox(height: 4),
                Text(
                  '${_group.members.length} members',
                  style: AppTextStyles.grey5C5C5C_16_600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: AppTextStyles.black16_600),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greyE5E7EB,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _group.description ?? 'No description',
              style: AppTextStyles.black14_400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Members', style: AppTextStyles.black16_600),
              if (isadmin)
                TextButton.icon(
                  onPressed: _addMembers,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _group.members.length,
            itemBuilder: (context, index) {
              final memberId = _group.members[index];
              final memberName = _getEmployeeName(memberId);
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(memberName),
                subtitle: Text(memberId),
                trailing: isadmin
                    ? IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: AppColors.errorRed,
                        ),
                        onPressed: () => _removeMember(memberId),
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTiles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (isadmin)
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Group Name'),
              onTap: _editGroupName,
            ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorRed),
            title: const Text('Leave Group'),
            onTap: _leaveGroup,
          ),
          if (isadmin)
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorRed),
              title: const Text('Delete Group'),
              onTap: _deleteGroup,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGroupHeader(),
            const Divider(height: 1, color: AppColors.dividerD9D9D9),
            _buildDescriptionSection(),
            const Divider(height: 1, color: AppColors.dividerD9D9D9),
            _buildMembersSection(),
            const Divider(height: 1, color: AppColors.dividerD9D9D9),
            _buildActionTiles(),
          ],
        ),
      ),
    );
  }
}
