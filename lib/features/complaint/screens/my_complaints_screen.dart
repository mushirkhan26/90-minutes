import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/features/complaint/provider/complaint_provider.dart';
import '../widgets/complaint_card.dart';
import 'create_complaint_bottomsheet.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _teamSearchController = TextEditingController();

  String _searchText = '';
  String _teamSearchText = '';
  String _selectedStatus = 'All';

  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();
    final bool isManager = provider.isManager;

    return Scaffold(
      backgroundColor: Colors.white,

      // ================== APP BAR ==================
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Complaints",
          style: TextStyle(color: Colors.white),
        ),

        actions: (!isManager || _currentTabIndex == 0)
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FBFC0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      "Create",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateComplaintBottomSheet(),
                        ),
                      );
                    },
                  ),
                )
              ]
            : [],
      ),

      // ================== BODY ==================
      body: isManager
          ? Column(
              children: [
                _managerTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _myComplaintsView(provider, isManager),
                      _teamComplaintsView(provider),
                    ],
                  ),
                ),
              ],
            )
          : _myComplaintsView(provider, isManager),
    );
  }

  // ================== MANAGER TABS ==================
  Widget _managerTabs() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF4FA3A5),
            borderRadius: BorderRadius.circular(25),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black87,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'My Complaints'),
            Tab(text: 'Team Complaints'),
          ],
        ),
      ),
    );
  }

  // ================== MY COMPLAINTS ==================
  Widget _myComplaintsView(ComplaintProvider provider, bool isManager) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value.toLowerCase().trim();
              });
            },
            decoration: InputDecoration(
              hintText: "Search by ID, Title, or Description",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (provider.isLoading && provider.complaints.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredComplaints = provider.complaints.where((c) {
                if (_searchText.isEmpty) return true;
                return c.title.toLowerCase().contains(_searchText) ||
                    c.description.toLowerCase().contains(_searchText) ||
                    c.id.toLowerCase().contains(_searchText);
              }).toList();

              if (filteredComplaints.isEmpty && !provider.isLoading) {
                return const Center(child: Text("No complaints found"));
              }

              return RefreshIndicator(
                onRefresh: () => provider.fetchComplaints(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    return ComplaintCard(
                      complaint: filteredComplaints[index],
                      isManagerView: isManager,
                      onUpdateStatus: isManager ? (status) => provider.updateComplaintStatus(
                        complaintId: filteredComplaints[index].id,
                        status: status,
                      ) : null,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================== TEAM COMPLAINTS ==================
  Widget _teamComplaintsView(ComplaintProvider provider) {
    if (provider.isLoading && provider.teamComplaints.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = provider.teamComplaints.where((c) {
      final textMatch = _teamSearchText.isEmpty ||
          c.title.toLowerCase().contains(_teamSearchText) ||
          c.id.toLowerCase().contains(_teamSearchText);

      final statusMatch = _selectedStatus == 'All' ||
          c.status.toLowerCase() == _selectedStatus.toLowerCase();

      return textMatch && statusMatch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _teamSearchController,
                  onChanged: (value) {
                    setState(() {
                      _teamSearchText = value.toLowerCase().trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search by ID, Title",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Status')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Investigating', child: Text('Investigating')),
                    DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty && !provider.isLoading
              ? const Center(
                  child: Text(
                    'No Team Complaints',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.fetchAllComplaints(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return ComplaintCard(
                        complaint: filtered[index],
                        isManagerView: true,
                        onUpdateStatus: (status) => provider.updateComplaintStatus(
                          complaintId: filtered[index].id,
                          status: status,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _teamSearchController.dispose();
    super.dispose();
  }
}
