import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/shared/shimmer_tile.dart';
import 'package:hrtz_hrms/features/service_request/providers/service_request_provider.dart';
import 'package:hrtz_hrms/features/service_request/widgets/service_request_model.dart';
import 'package:hrtz_hrms/features/service_request/widgets/service_request_bottom_sheet.dart';
import 'package:hrtz_hrms/features/service_request/screens/service_request_list_screen.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/service_request/screens/add_service_request_screen.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  String _searchQuery = '';
  int _currentPage = 1;
  final int _pageSize = 5;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final role = context
        .read<AuthProvider>()
        .userData?['role']
        ?.toString()
        .toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          role == 'manager' ? 'Manage your Requests' : 'Service Requests',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ServiceRequestProvider>(
        builder: (_, provider, __) {
          return role == 'manager'
              ? _managerView(size)
              : _userView(size);
        },
      ),
    );
  }

  // ================= MANAGER VIEW (UNCHANGED) =================
  Widget _managerView(Size size) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSearchBar(size),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          child: _buildCountsSection(size),
        ),
        const SizedBox(height: 16),
        _buildRequestsList(size),
      ],
    );
  }

  // ================= USER VIEW =================
  Widget _userView(Size size) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSearchBar(size),
        const SizedBox(height: 8),
        _buildUserCategories(size),
        const SizedBox(height: 20),
        _buildUserPreviousRequests(size),
      ],
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.04),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
            _currentPage = 1;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for Requests',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= USER CATEGORIES =================
  Widget _buildUserCategories(Size size) {
    return Consumer<ServiceRequestProvider>(
      builder: (_, provider, __) {
        if (provider.state == ServiceRequestState.loading &&
            provider.requestCounts.isEmpty) {
          return const ShimmerTile(height: 120);
        }

        final categories = provider.requestCounts.entries
            .where((e) => e.key != 'Total Requests')
            .toList();

        IconData _getIcon(String type) {
          switch (type.toLowerCase()) {
            case 'hardware':
              return Icons.build;
            case 'software':
              return Icons.computer;
            case 'backup':
              return Icons.backup;
            case 'document':
              return Icons.description;
            default:
              return Icons.miscellaneous_services;
          }
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (_, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddServiceRequestScreen(
                        requestType: category.key,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIcon(category.key),
                        size: 36,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category.key,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Click here if you need help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= USER PREVIOUS REQUESTS (WEB STYLE) =================
  Widget _buildUserPreviousRequests(Size size) {
    return Consumer<ServiceRequestProvider>(
      builder: (_, provider, __) {
        if (provider.isUserRequestLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: const ShimmerTile(height: 160),
          );
        }

        if (provider.allRequests.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(size.width * 0.08),
            child: const Text(
              'No previous requests',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Previous Requests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...provider.allRequests.map(_userWebCard),
            ],
          ),
        );
      },
    );
  }

  Widget _userWebCard(ServiceRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Text(
                'Status: ${r.requestStatus}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.department,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(r.createdOn),
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 24),
                _row('Request ID', r.requestId),
                _row('Name', r.name),
                _row('Employee ID', r.employeeId),
                _row('Email', r.email),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(r.description),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

 
  // ================= COUNTS =================
  Widget _buildCountsSection(Size size) {
    return Consumer<ServiceRequestProvider>(
      builder: (_, provider, __) {
        if (provider.state == ServiceRequestState.loading &&
            provider.requestCounts.isEmpty) {
          return _buildCountsShimmer(size);
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: size.height * 0.02,
            crossAxisSpacing: size.width * 0.04,
            childAspectRatio: 1.6,
            children: provider.requestCounts.entries
                .map(
                  (e) => _buildCountCard(
                    title: e.key,
                    count: e.value,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildCountsShimmer(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: 6,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: size.width * 0.04,
          mainAxisSpacing: size.height * 0.02,
          childAspectRatio: 1.6,
        ),
        itemBuilder: (_, __) => const ShimmerTile(height: 70),
      ),
    );
  }

 Widget _buildCountCard({required String title, required int count}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
         builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ServiceRequestProvider>(),
          child: ServiceRequestListScreen(
            title: title,
            filterType: title == 'Total Requests'
            ? null
            : title.split(' ')[0],
          ),

         ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

  // ================= REQUEST LIST =================
  Widget _buildRequestsList(Size size) {
  return Consumer<ServiceRequestProvider>(
    builder: (_, provider, __) {
      if (provider.state == ServiceRequestState.loading &&
          provider.allRequests.isEmpty) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          padding: EdgeInsets.all(size.width * 0.04),
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.02),
            child: const ShimmerTile(height: 90),
          ),
        );
      }

      final filtered = provider.allRequests.where((r) {
        return r.name.toLowerCase().contains(_searchQuery) ||
        r.description.toLowerCase().contains(_searchQuery) ||
            r.type.toLowerCase().contains(_searchQuery) ||
            r.managerName.toLowerCase().contains(_searchQuery);
      }).toList();

      // 🔍 SEARCH RESULT EMPTY STATE (LIST ONLY)
if (_searchQuery.isNotEmpty && filtered.isEmpty) {
  return Padding(
    padding: EdgeInsets.all(size.width * 0.08),
    child: Column(
      children: const [
        Icon(Icons.search_off, size: 56, color: Colors.grey),
        SizedBox(height: 10),
        Text(
          'No matching requests',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

      // ✅ PAGINATION LOGIC
      final totalItems = filtered.length;
      final totalPages = (totalItems / _pageSize).ceil();

      final startIndex = (_currentPage - 1) * _pageSize;
      final endIndex =
          (_currentPage * _pageSize).clamp(0, totalItems);

      final paginatedList =
          totalItems > 0 ? filtered.sublist(startIndex, endIndex) : [];

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              size.width * 0.04,
              size.width * 0.04,
              size.width * 0.04,
              12,
            ),
            itemCount: paginatedList.length,
            itemBuilder: (_, index) =>
                _buildRequestCard(paginatedList[index], size, index, startIndex),
          ),

          // ✅ PAGINATION FOOTER (WEB STYLE)
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Showing ${startIndex + 1}–$endIndex of $totalItems',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 10),

                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                  ),

                  Text(
                    'Page $_currentPage of $totalPages',
                    style:
                        const TextStyle(fontWeight: FontWeight.w500),
                  ),

                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < totalPages
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}
  // ================= REQUEST CARD (WEB STYLE) =================
  Widget _buildRequestCard(ServiceRequest request, Size size, int index, int startIndex) {
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Container(

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:  0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.computer,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  request.type,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text('Dept: ${request.department}'),
          Text('Employee ID: ${request.employeeId}'),
          Text('Mobile: ${request.mobile}'),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha:  0.15),
              child: IconButton(
                icon: const Icon(Icons.remove_red_eye),
                color: AppColors.primary,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ServiceRequestBottomSheet(request: request, requestIndex: index + 1),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}