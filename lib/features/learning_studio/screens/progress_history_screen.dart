import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/learning_studio_provider.dart';

class ProgressHistoryScreen extends StatefulWidget {
  const ProgressHistoryScreen({super.key});

  @override
  State<ProgressHistoryScreen> createState() => _ProgressHistoryScreenState();
}

class _ProgressHistoryScreenState extends State<ProgressHistoryScreen> {
  bool showFilters = false;
  String? selectedDate;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningStudioProvider>();
    final progressHistory = provider.progressHistory ?? [];

    /// ================= FILTER LOGIC =================
    final filteredHistory = progressHistory.where((item) {
      bool matches = true;

      // STATUS FILTER
      if (selectedStatus != null) {
        matches = matches && item['courseStatus'] == selectedStatus;
      }

      

      // DATE FILTER
      if (selectedDate != null && item['startDate'] != null) {
        final date = DateTime.parse(item['startDate']);
        final now = DateTime.now();

        if (selectedDate == 'Today') {
          matches = matches &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }

        if (selectedDate == 'Yesterday') {
          final y = now.subtract(const Duration(days: 1));
          matches = matches &&
              date.year == y.year &&
              date.month == y.month &&
              date.day == y.day;
        }

        if (selectedDate == 'Last Week') {
          matches = matches &&
              date.isAfter(now.subtract(const Duration(days: 7)));
        }
      }

      return matches;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF26A69A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Learning Studio > Progress History',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: provider.state == LearningStudioState.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= FILTER BAR =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            showFilters = !showFilters;
                          });
                        },
                        icon: Icon(
                          showFilters ? Icons.close : Icons.filter_alt_outlined,
                          color: const Color(0xFF26A69A),
                        ),
                        label: Text(showFilters ? 'Close Filters' : 'Filter By'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            selectedDate = null;
                            selectedStatus = null;
                          });
                        },
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ================= FILTER CARD =================
                  if (showFilters) ...[
                    _filterCard(),

                  const SizedBox(height: 16),
                  ],

                  /// ================= PROGRESS HISTORY =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (filteredHistory.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: Text('No records found')),
                          ),

                        ...filteredHistory.map(
                          (item) => _ProgressHistoryItem(item: item),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// ================= FILTER UI =================
  Widget _filterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _dropdown(
            label: 'Date',
            value: selectedDate,
            items: const ['Today', 'Yesterday', 'Last Week'],
            onChanged: (v) => setState(() => selectedDate = v),
          ),
          
          _dropdown(
            label: 'Status',
            value: selectedStatus,
            items: const ['NotStarted', 'Ongoing', 'Completed'],
            onChanged: (v) => setState(() => selectedStatus = v),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(value: e, child: Text(e)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

/// ================= SINGLE CARD =================
class _ProgressHistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ProgressHistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item['courseStatus'];
    Color color = status == 'Completed'
        ? Colors.green
        : status == 'Ongoing'
            ? Colors.orange
            : Colors.brown;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE8F5F3),
              child: Text(
                _getInitials(item['name']),
                style: const TextStyle(
                  color: Color(0xFF26A69A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  item['department'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  item['courseName'] ?? '',
                  style: const TextStyle(color: Color(0xFF26A69A)),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status, style: TextStyle(color: color)),
              const SizedBox(height: 4),
              Text(
                _formatDate(item['startDate']),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ================= DATE FORMAT =================
String _formatDate(String? d) {
  if (d == null) return '';
  final dt = DateTime.parse(d);
  return '${dt.day}/${dt.month}/${dt.year}';
}

String _getInitials(String? name) {
  if (name == null) return '';

  final cleaned = name.trim();
  if (cleaned.isEmpty) return '';

  final parts = cleaned.split(RegExp(r'\s+'));

  if (parts.length == 1) {
    return parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '';
  }

  final first = parts[0].isNotEmpty ? parts[0][0] : '';
  final second = parts[1].isNotEmpty ? parts[1][0] : '';

  return (first + second).toUpperCase();
}