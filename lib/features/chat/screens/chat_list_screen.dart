import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/core/constants/app_constants.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart' show AuthProvider;
import 'package:hrtz_hrms/features/chat/widgtes/employee_list_card.dart';
import 'package:hrtz_hrms/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<EmployeeModel> _filteredEmployees = [];
  List<EmployeeModel> _allEmployees = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEmployees);
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _allEmployees.where((employee) {
        return employee.name.toLowerCase().contains(query) ||
            employee.employeeID.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AuthProvider>().refreshEmployeeList();
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
              onChanged: (value) => _filterEmployees(),
              hintText: 'Search employees...',
            ),
          ),

          // Employee list
          Expanded(
            child: _filteredEmployees.isEmpty
                ? const Center(
                    child: Text('No employees found', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = _filteredEmployees[index];
                      return EmployeeListCard(
                        name: employee.name,
                        message: 'Tap to start chat',
                        time: null, // We'll use current time when message is sent
                        isActive: true, // You can implement presence status later
                        onTap: () {
                          // Navigate to individual chat
                          context.goToIndividualChat(
                            otherUserId: employee.employeeID,
                            otherUserName: employee.name,
                          );
                        },
                        unreadCount: 0, // You can implement unread count logic later
                        isAccountDeleted: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
