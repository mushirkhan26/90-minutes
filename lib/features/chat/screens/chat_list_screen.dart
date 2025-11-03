import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/core/extensions/secure_storage_extension.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/core/socket/group_socket_provider.dart';
import 'package:hrtz_hrms/core/socket/socket_provider.dart';
import 'package:hrtz_hrms/core/utils/alert_utils.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart' show AuthProvider;
import 'package:hrtz_hrms/features/chat/widgtes/employee_list_card.dart';
import 'package:hrtz_hrms/features/chat/widgtes/group_chat_list_tile.dart';
import 'package:hrtz_hrms/widgets/custom_button.dart';
import 'package:hrtz_hrms/widgets/custom_search_bar.dart';
import 'package:hrtz_hrms/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<EmployeeModel> _filteredEmployees = [];
  List<EmployeeModel> _allEmployees = [];
  final List<EmployeeModel> _selectedMembers = [];
  Timer? _debounce;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_filterEmployees);
    _loadEmployees();
    _loadGroupChats();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.employeeList != null) {
      setState(() {
        _allEmployees = List.from(authProvider.employeeList!);
        _filteredEmployees = List.from(authProvider.employeeList!);
      });
    }
  }

  /// Loads the list of group chats from the group socket provider.
  Future<void> _loadGroupChats() async {
    final groupSocketProvider = context.read<GroupSocketProvider>();
    await groupSocketProvider.fetchUserGroups();
  }

  void _filterEmployees() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredEmployees = _allEmployees.where((employee) {
          return employee.name.toLowerCase().contains(query) ||
              employee.employeeID.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  /// Filters the list of group chats based on the search query.
  List<GroupChatModel> _filterGroupChats(List<GroupChatModel> groupChats) {
    final query = _searchController.text.toLowerCase();
    return groupChats.where((group) {
      return group.name.toLowerCase().contains(query);
    }).toList();
  }

  /// Opens dialog to create a new group
  /// Opens dialog to create a new group
  Future<void> _showCreateGroupDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    _selectedMembers.clear();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Create New Group',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(controller: nameController, hintText: "Group Name"),
                    const SizedBox(height: 10),
                    CustomTextField(controller: descController, hintText: "Description (optional)"),
                    const SizedBox(height: 16),
                    const Text('Select Members', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _allEmployees.length,
                        itemBuilder: (context, index) {
                          final emp = _allEmployees[index];
                          final selected = _selectedMembers.contains(emp);
                          return CheckboxListTile(
                            title: Text(emp.name),
                            subtitle: Text(emp.employeeID),
                            value: selected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
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
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Cancel",
                        backgroundColor: Colors.grey.shade300,
                        textColor: Colors.black87,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: CustomButton(
                        text: "Create Group",

                        fontSize: 10,
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            if (mounted) {
                              AlertHelper.snackBarWarning(context, 'Please enter a group name');
                            }
                            return;
                          }
                          if (_selectedMembers.isEmpty) {
                            if (mounted) {
                              AlertHelper.snackBarWarning(
                                context,
                                'Please select at least one member',
                              );
                            }
                            return;
                          }

                          Navigator.pop(context); // close dialog
                          final createdBy = await context.getCurrentEmployeeId();
                          if (createdBy == null) {
                            if (context.mounted) {
                              AlertHelper.snackBarError(context, 'User ID not found in storage');
                            }
                            return;
                          }

                          await _createGroup(
                            name: name,
                            description: descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            createdBy: createdBy,
                            members: _selectedMembers.map((e) => e.employeeID).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Handles group creation via socket
  Future<void> _createGroup({
    required String name,
    required String createdBy,
    required List<String> members,
    String? description,
  }) async {
    final groupProvider = context.read<GroupSocketProvider>();
    try {
      await groupProvider.createGroup(
        name: name,
        createdBy: createdBy,
        members: members,
        description: description,
      );

      if (mounted) {
        AlertHelper.snackBarSuccess(context, '✅ Group created successfully');
      }
    } catch (e) {
      if (mounted) {
        AlertHelper.snackBarError(context, '❌ Failed to create group: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final groupSocketProvider = context.watch<GroupSocketProvider>();

    // If we're still fetching employees, show loading indicator
    if (authProvider.isFetchingEmployees && _allEmployees.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If we have employees from the provider, update our local list
    if (authProvider.employeeList != null &&
        authProvider.employeeList!.length != _allEmployees.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _allEmployees = List.from(authProvider.employeeList!);
          _filterEmployees(); // Re-filter with current search query
        });
      });
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Individual"),
              Tab(text: "Groups"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AuthProvider>().refreshEmployeeList();
                context.read<GroupSocketProvider>().fetchUserGroups();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomSearchBar(
                enable: true,
                controller: _searchController,
                onChanged: (value) {
                  _filterEmployees();
                  setState(() {}); // Trigger rebuild to update group chat filter
                },
                hintText: 'Search...',
              ),
            ),

            // Employee list
            // Expanded(
            //   child: _filteredEmployees.isEmpty
            //       ? const Center(
            //           child: Text('No employees found', style: TextStyle(color: Colors.grey)),
            //         )
            //       : ListView.builder(
            //           padding: EdgeInsets.all(AppConstants.paddingMedium),
            //           itemCount: _filteredEmployees.length,
            //           itemBuilder: (context, index) {
            //             final employee = _filteredEmployees[index];

            //             final unreadCount =
            //                 context.watch<SocketProvider>().unreadCounts[employee.employeeID] ?? 0;
            //             return EmployeeListCard(
            //               name: employee.name,
            //               message: 'Tap to start chat',
            //               time: null, // We'll use current time when message is sent
            //               isActive: true, // You can implement presence status later
            //               onTap: () {
            //                 // Navigate to individual chat
            //                 context.goToIndividualChat(
            //                   otherUserId: employee.employeeID,
            //                   otherUserName: employee.name,
            //                 );
            //               },
            //               unreadCount: unreadCount, // You can implement unread count logic later
            //               isAccountDeleted: false,
            //             );
            //           },
            //         ),
            // ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Individual chats tab
                  _buildIndividualChatsTab(authProvider),
                  // Group chats tab
                  _buildGroupChatsTab(groupSocketProvider),
                ],
              ),
            ),
          ],
        ),

        /// FAB for creating a group (only on "Groups" tab)
        floatingActionButton: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return _tabController.index == 1
                ? FloatingActionButton.extended(
                    icon: const Icon(Icons.group_add),
                    label: const Text("Create Group"),
                    onPressed: _showCreateGroupDialog,
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Builds the individual chats tab.
  Widget _buildIndividualChatsTab(AuthProvider authProvider) {
    final socketProvider = context.watch<SocketProvider>();

    if (_filteredEmployees.isEmpty) {
      return const Center(
        child: Text('No employees found', style: TextStyle(color: Colors.grey)),
      );
    }

    return StreamBuilder<Map<String, String>>(
      stream: socketProvider.presenceStream,
      initialData: const {},
      builder: (context, snapshot) {
        final presenceData = snapshot.data ?? {};
        final onlineIds = socketProvider.onlineUsers.toSet();
        final recentIds = socketProvider.recentChats; // 🕓 from storage

        // 🔹 Sort employees by recent first, then online, then offline by name
        final sortedEmployees = List<EmployeeModel>.from(_filteredEmployees)
          ..sort((a, b) {
            // 1️⃣ Recent first
            final aRecentIndex = recentIds.indexOf(a.employeeID);
            final bRecentIndex = recentIds.indexOf(b.employeeID);
            final aIsRecent = aRecentIndex != -1;
            final bIsRecent = bRecentIndex != -1;

            if (aIsRecent && !bIsRecent) return -1;
            if (!aIsRecent && bIsRecent) return 1;
            if (aIsRecent && bIsRecent) {
              // Lower index = more recent
              return aRecentIndex.compareTo(bRecentIndex);
            }

            // 2️⃣ Then online before offline
            final aOnline = onlineIds.contains(a.employeeID);
            final bOnline = onlineIds.contains(b.employeeID);
            if (aOnline && !bOnline) return -1;
            if (!aOnline && bOnline) return 1;

            // 3️⃣ Finally, alphabetical
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

        return ListView.builder(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: sortedEmployees.length,
          itemBuilder: (context, index) {
            final employee = sortedEmployees[index];
            final isActive = onlineIds.contains(employee.employeeID);
            final unreadCount = socketProvider.unreadCounts[employee.employeeID] ?? 0;
            final statusText = presenceData[employee.employeeID] ?? "Offline";

            return EmployeeListCard(
              name: employee.name,
              message: "Tap to open chat",
              time: statusText, // "Online" or "2 hr ago"
              isActive: isActive,
              onTap: () async {
                socketProvider.resetUnreadCount(employee.employeeID);
                await socketProvider.markUserAsRecentlyChatted(
                  employee.employeeID,
                ); // 🕓 Save recent
                if (context.mounted) {
                  context.goToIndividualChat(
                    otherUserId: employee.employeeID,
                    otherUserName: employee.name,
                  );
                }
              },
              unreadCount: unreadCount,
              isAccountDeleted: false,
            );
          },
        );
      },
    );
  }

  /// Builds the group chats tab.
  Widget _buildGroupChatsTab(GroupSocketProvider groupSocketProvider) {
    final filteredGroupChats = _filterGroupChats(groupSocketProvider.groupChats);
    if (filteredGroupChats.isEmpty) {
      return const Center(
        child: Text('No group chats found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: filteredGroupChats.length,
      itemBuilder: (context, index) {
        final groupChat = filteredGroupChats[index];
        final unreadCount = groupSocketProvider.groupUnreadCounts[groupChat.groupId] ?? 0;
        return GroupChatTile(
          groupName: groupChat.name,
          lastMessage: 'Tap to open chat',
          time: groupChat.createdAt,
          unreadCount: unreadCount,
          onTap: () {
            context.goToGroupChat(
              groupId: groupChat.groupId,
              groupName: groupChat.name,
              groupModel: groupChat,
            );
          },
        );
      },
    );
  }
}
