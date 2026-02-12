import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../widgets/service_request_model.dart';
import '../widgets/service_request_bottom_sheet.dart';
import '../../../config/theme/app_colors.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';






class ServiceRequestListScreen extends StatefulWidget {
  final String title;
  final String? filterType;

  const ServiceRequestListScreen({
    super.key,
    required this.title,
    this.filterType,
  });

  @override
  State<ServiceRequestListScreen> createState() =>
      _ServiceRequestListScreenState();
}

class _ServiceRequestListScreenState
    extends State<ServiceRequestListScreen> {
  String search = '';

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Requests > ${widget.title}',
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<ServiceRequestProvider>(
        builder: (_, provider, __) {
          List<ServiceRequest> list = provider.allRequests;

          // 🔹 Filter based on grid click
          if (widget.filterType != null) {
            list = list
                .where((e) =>
                    e.type.toLowerCase().contains(
                    widget.filterType!.toLowerCase(),
                    )
                ).toList();
          }

          // 🔹 Search
          list = list.where((e) {
            return e.name.toLowerCase().contains(search) ||
                e.email.toLowerCase().contains(search) ||
                e.employeeId.toLowerCase().contains(search);
          }).toList();

          return Column(
            children: [
              _searchBar(),
              _excelIcon(list),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, index) =>
                      _requestCard(list[index], index),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (v) => setState(() => search = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search by name, email or ID...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _excelIcon(List<ServiceRequest> filteredList) {
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _exportToExcel(filteredList),
        child: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.file_download, color: Colors.white),
        ),
      ),
    ),
  );
}
  Widget _requestCard(ServiceRequest r, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Chip(
                label: Text(
                  r.requestStatus,
                  style: TextStyle(
                    color: _statusTextColor(r.requestStatus),
                    fontWeight: FontWeight.w600
                  ),
                ),
                backgroundColor: _statusBgColor(r.requestStatus),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Dept: ${r.department}'),
          Text('Employee ID: ${r.employeeId}'),
          Text('Mobile: ${r.mobile}'),
          Text('Type: ${r.type}'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.remove_red_eye,
                    color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ServiceRequestBottomSheet(
                      request: r,
                      requestIndex: index + 1,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusBgColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green.shade100;
    case 'waiting':
    case 'pending':
      return Colors.grey.shade300;
    case 'rejected':
      return Colors.red.shade100;
    default:
      return Colors.grey.shade300;
  }
}

Color _statusTextColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green.shade800;
    case 'waiting':
    case 'pending':
      return Colors.grey.shade800;
    case 'rejected':
      return Colors.red.shade800;
    default:
      return Colors.grey.shade800;
  }
}

Future<void> _exportToExcel(List<ServiceRequest> requests) async {
  try {
    if (requests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = widget.title;

    final headers = [
      'Department',
      'Employee ID',
      'Name',
      'Email',
      'Mobile',
      'Manager Name',
      'Admin Comment',
      'Request ID',
      'Status',
      'Type',
      'Created On',
      'Description',
      'Attachment URL',
      'Video URL',
    ];

    for (int col = 0; col < headers.length; col++) {
      sheet.getRangeByIndex(1, col + 1).setText(headers[col]);
      sheet.getRangeByIndex(1, col + 1).cellStyle.bold = true;
    }

    for (int row = 0; row < requests.length; row++) {
      final r = requests[row];

      sheet.getRangeByIndex(row + 2, 1).setText(r.department);
sheet.getRangeByIndex(row + 2, 2).setText(r.employeeId.toString());
sheet.getRangeByIndex(row + 2, 3).setText(r.name);
sheet.getRangeByIndex(row + 2, 4).setText(r.email);
sheet.getRangeByIndex(row + 2, 5).setText(r.mobile.toString());
sheet.getRangeByIndex(row + 2, 6).setText(r.managerName);
sheet.getRangeByIndex(row + 2, 7).setText(r.adminComment);
sheet.getRangeByIndex(row + 2, 8).setText(r.requestId.toString());
sheet.getRangeByIndex(row + 2, 9).setText(r.requestStatus);
sheet.getRangeByIndex(row + 2, 10).setText(r.type);
sheet.getRangeByIndex(row + 2, 11).setText(r.createdOn.toString());
sheet.getRangeByIndex(row + 2, 12).setText(r.description);
sheet.getRangeByIndex(row + 2, 13)
    .setText(r.attachmentUrl.join(", "));
sheet.getRangeByIndex(row + 2, 14).setText(r.videoUrl);
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        "${directory.path}/${widget.title}_${DateTime.now().millisecondsSinceEpoch}.xlsx";

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    await OpenFile.open(filePath);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel Downloaded Successfully")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Export failed: $e")),
    );
  }
}
}