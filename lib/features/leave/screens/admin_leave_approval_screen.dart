import 'package:flutter/material.dart';
import 'package:hrtz_hrms/features/leave/provider/leave_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/alert_utils.dart';

class AdminLeaveApprovalScreen extends StatefulWidget {
  const AdminLeaveApprovalScreen({super.key});

  @override
  State<AdminLeaveApprovalScreen> createState() => _AdminLeaveApprovalScreenState();
}

class _AdminLeaveApprovalScreenState extends State<AdminLeaveApprovalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedEmployeeId;
  DateTime? _selectedStartDate;
  String? _updatingLeaveId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaveProvider>().fetchAllLeaveRequests();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedEmployeeId = null;
      _selectedStartDate = null;
    });
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    final String dateStr = dateValue.toString();
    if (dateStr.isEmpty) return 'N/A';
    
    try {
      DateTime? dt;
      if (dateStr.contains('T')) {
        dt = DateTime.tryParse(dateStr);
      } else if (dateStr.contains('-')) {
        dt = DateTime.tryParse(dateStr);
      } else if (dateStr.contains('/')) {
        dt = DateFormat('M/d/yyyy').parse(dateStr);
      }
      
      if (dt != null) {
        return DateFormat('MMM dd, yyyy').format(dt);
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final allRequests = context.select<LeaveProvider, List<dynamic>>((p) => p.allLeaveRequests);
    final isLoading = context.select<LeaveProvider, bool>((p) => p.isLoading);
    
    final query = _searchController.text.toLowerCase().trim();

    final filteredRequests = allRequests.where((leave) {
      if (query.isNotEmpty) {
        final name = (leave['name'] ?? '').toString().toLowerCase();
        final empId = (leave['employeeId'] ?? '').toString().toLowerCase();
        final reason = (leave['reason'] ?? '').toString().toLowerCase();
        final type = (leave['type'] ?? '').toString().toLowerCase();
        if (!(name.contains(query) || empId.contains(query) || reason.contains(query) || type.contains(query))) {
          return false;
        }
      }

      if (_selectedEmployeeId != null && leave['employeeId'] != _selectedEmployeeId) {
        return false;
      }

      if (_selectedStartDate != null) {
        final String startDateStr = (leave['startDate'] ?? '').toString();
        if (startDateStr.isEmpty) return false;

        try {
          DateTime? apiDate;
          if (startDateStr.contains('T')) {
            apiDate = DateTime.tryParse(startDateStr);
          } else if (startDateStr.contains('-')) {
            apiDate = DateTime.tryParse(startDateStr);
          } else if (startDateStr.contains('/')) {
            apiDate = DateFormat('M/d/yyyy').parse(startDateStr);
          }

          if (apiDate != null) {
            if (apiDate.year != _selectedStartDate!.year || 
                apiDate.month != _selectedStartDate!.month || 
                apiDate.day != _selectedStartDate!.day) {
              return false;
            }
          }
        } catch (_) {
          return false;
        }
      }

      return true;
    }).toList();

    final List<String> employeeIds = allRequests
        .map((e) => e['employeeId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Leave Approval', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(employeeIds, filteredRequests.length),
          
          if (isLoading && filteredRequests.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF26A69A))))
          else if (filteredRequests.isEmpty)
            const Expanded(child: Center(child: Text('No leave history found')))
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: RefreshIndicator(
                    onRefresh: () => context.read<LeaveProvider>().fetchAllLeaveRequests(),
                    color: const Color(0xFF26A69A),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 1100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _TableHeader(),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: filteredRequests.length,
                                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                                itemBuilder: (context, index) {
                                  final leave = filteredRequests[index];
                                  final leaveId = (leave['leaveId'] ?? leave['_id']).toString();
                                  return _LeaveDataRow(
                                    leave: leave,
                                    isUpdating: _updatingLeaveId == leaveId,
                                    onUpdateStatus: (id, status) => _updateStatus(id, status),
                                    onShowDetails: () => _showLeaveDetails(leave),
                                    formatDate: _formatDate,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<String> employeeIds, int count) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search name, ID, reason...',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedEmployeeId,
                      isExpanded: true,
                      hint: const Text('ID', style: TextStyle(fontSize: 12)),
                      items: employeeIds.map((id) => DropdownMenuItem(value: id, child: Text(id, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (val) => setState(() => _selectedEmployeeId = val),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context, 
                      initialDate: _selectedStartDate ?? DateTime.now(), 
                      firstDate: DateTime(2020), 
                      lastDate: DateTime(2100),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: Color(0xFF26A69A)),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) setState(() => _selectedStartDate = date);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF26A69A)),
                  label: Text(
                    _selectedStartDate == null ? 'Start Date' : DateFormat('yyyy/MM/dd').format(_selectedStartDate!),
                    style: const TextStyle(fontSize: 12, color: Colors.black87)
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.redAccent),
                  label: const Text('Reset', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                ),
                const SizedBox(width: 8),
                Text('$count Records Found', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String leaveId, String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('$status Leave'),
        content: Text('Are you sure you want to set this leave to $status?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Confirm', style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final leaveProvider = context.read<LeaveProvider>();
      setState(() => _updatingLeaveId = leaveId);
      
      final (success, message) = await leaveProvider.updateLeaveStatus(leaveId: leaveId, status: status);
      
      if (mounted) {
        setState(() => _updatingLeaveId = null);
        if (success) {
          AlertHelper.snackBarSuccess(context, message);
        } else {
          AlertHelper.snackBarError(context, message);
        }
      }
    }
  }

  void _showLeaveDetails(Map<String, dynamic> leave) {
    final bool isEmergency = (leave['type'] ?? '').toString().toLowerCase() == 'emergencyleave';
    final List<dynamic> certs = leave['medicalCertificate'] ?? [];
    final String? certUrl = certs.isNotEmpty ? certs[0].toString() : null;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF26A69A), 
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12))
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Leave Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        leave['leaveStatus'] ?? 'Pending', 
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailItemRow(label: 'Employee:', value: leave['name'], icon: Icons.person_outline),
                    _DetailItemRow(label: 'Employee ID:', value: leave['employeeId'], icon: Icons.badge_outlined),
                    _DetailItemRow(label: 'Manager:', value: leave['managerName'] ?? 'N/A', icon: Icons.supervisor_account_outlined),
                    _DetailItemRow(label: 'Leave Type:', value: leave['type'], icon: Icons.category_outlined),
                    _DetailItemRow(label: 'Duration:', value: '${leave['duration']} day(s)', icon: Icons.timer_outlined),
                    _DetailItemRow(label: 'From:', value: _formatDate(leave['startDate']), icon: Icons.calendar_today_outlined),
                    _DetailItemRow(label: 'To:', value: _formatDate(leave['endDate']), icon: Icons.calendar_today),

                    if (isEmergency && certUrl != null) ...[
                      const Divider(height: 24),
                      const Text('Medical Certificate:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showFullScreenImage(certUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                certUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, e, s) => Container(
                                  height: 120,
                                  color: Colors.grey.shade100,
                                  child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
                                ),
                              ),
                              Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.black26,
                                child: const Icon(Icons.fullscreen, color: Colors.white, size: 30),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    const Text('Reason:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50, 
                        borderRadius: BorderRadius.circular(8), 
                        border: Border.all(color: Colors.grey.shade200)
                      ),
                      child: Text(leave['reason'] ?? 'N/A', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (ctx, e, s) => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white, size: 50),
                        SizedBox(height: 10),
                        Text('Failed to load image', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved': return const Color(0xFF4CAF50);
      case 'rejected': return const Color(0xFFF44336);
      case 'waiting': return const Color(0xFFFF9800);
      case 'pending': return const Color(0xFFFF9800);
      case 'cancelled': return const Color(0xFFEF5350);
      default: return Colors.grey;
    }
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF26A69A),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: const Row(
        children: [
          _HeaderCell('Name', flex: 2),
          _HeaderCell('Employee ID', flex: 2),
          _HeaderCell('Duration', flex: 1),
          _HeaderCell('Requested Date', flex: 2),
          _HeaderCell('Start Date', flex: 2),
          _HeaderCell('End Date', flex: 2),
          _HeaderCell('Type', flex: 2),
          _HeaderCell('Status', flex: 3),
        ],
      ),
    );
  }
}

class _LeaveDataRow extends StatelessWidget {
  final Map<String, dynamic> leave;
  final bool isUpdating;
  final Function(String, String) onUpdateStatus;
  final VoidCallback onShowDetails;
  final String Function(dynamic) formatDate;

  const _LeaveDataRow({
    required this.leave,
    required this.isUpdating,
    required this.onUpdateStatus,
    required this.onShowDetails,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final status = leave['leaveStatus'] ?? 'Pending';
    final leaveId = (leave['leaveId'] ?? leave['_id'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.white,
      child: Row(
        children: [
          _DataCell(leave['name'] ?? 'N/A', flex: 2, isBold: true),
          _DataCell(leave['employeeId'] ?? 'N/A', flex: 2),
          _DataCell('${leave['duration']}', flex: 1),
          _DataCell(formatDate(leave['createdOn']), flex: 2),
          _DataCell(formatDate(leave['startDate']), flex: 2),
          _DataCell(formatDate(leave['endDate']), flex: 2),
          _DataCell(leave['type'] ?? 'N/A', flex: 2),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatusDropdown(
                  leaveId: leaveId,
                  currentStatus: status,
                  isUpdating: isUpdating,
                  onChanged: (newStatus) => onUpdateStatus(leaveId, newStatus),
                ),
                const SizedBox(width: 8),
                Material(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: onShowDetails,
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.visibility, color: Color(0xFF26A69A), size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String leaveId;
  final String currentStatus;
  final bool isUpdating;
  final Function(String) onChanged;

  const _StatusDropdown({
    required this.leaveId,
    required this.currentStatus,
    required this.isUpdating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isUpdating) {
      return Container(
        height: 32,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _getStatusColor(currentStatus).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    if (currentStatus.toLowerCase() == 'cancelled') {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _getStatusColor('Cancelled'),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Cancelled',
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      );
    }

    List<String> options = [];
    final lowerStatus = currentStatus.toLowerCase();
    if (lowerStatus == 'waiting' || lowerStatus == 'pending') {
      options = ['Waiting', 'Approved', 'Cancelled'];
    } else if (lowerStatus == 'approved') {
      options = ['Approved', 'Cancelled'];
    } else {
      options = [currentStatus, 'Approved', 'Cancelled', 'Waiting'];
    }

    // Ensure uniqueness and valid value
    final List<String> uniqueOptions = options.toSet().toList();
    String dropdownValue = uniqueOptions.any((o) => o.toLowerCase() == lowerStatus) 
        ? uniqueOptions.firstWhere((o) => o.toLowerCase() == lowerStatus) 
        : uniqueOptions.first;
        
    Color color = _getStatusColor(currentStatus);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
          selectedItemBuilder: (BuildContext context) {
            return uniqueOptions.map((String val) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              );
            }).toList();
          },
          items: uniqueOptions.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: TextStyle(color: _getStatusColor(val), fontSize: 12, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: (newStatus) {
            if (newStatus != null && newStatus.toLowerCase() != lowerStatus) {
              onChanged(newStatus);
            }
          },
        ),
      ),
    );
  }

  static Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved': return const Color(0xFF4CAF50);
      case 'rejected': return const Color(0xFFF44336);
      case 'waiting': return const Color(0xFFFF9800);
      case 'pending': return const Color(0xFFFF9800);
      case 'cancelled': return const Color(0xFFEF5350);
      default: return Colors.grey;
    }
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex, 
    child: Text(
      text, 
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), 
      textAlign: TextAlign.center
    )
  );
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isBold;
  const _DataCell(this.text, {required this.flex, this.isBold = false});
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex, 
    child: Text(
      text, 
      style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black87), 
      textAlign: TextAlign.center, 
      maxLines: 2, 
      overflow: TextOverflow.ellipsis
    )
  );
}

class _DetailItemRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _DetailItemRow({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF26A69A)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black54), overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
