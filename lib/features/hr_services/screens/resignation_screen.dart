import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/resignation_provider.dart';
import 'package:hrtz_hrms/features/auth/providers/auth_provider.dart';
import 'package:hrtz_hrms/features/hr_services/screens/resignation_details_card.dart';
import 'package:hrtz_hrms/features/hr_services/widgets/resignation_my_details.card.dart ';

class ResignationScreen extends StatefulWidget {
  const ResignationScreen({super.key});

  @override
  State<ResignationScreen> createState() => _ResignationScreenState();
}

class _ResignationScreenState extends State<ResignationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController reasonController = TextEditingController();

  DateTime? resignationDate;
  DateTime? lastWorkingDate;

  final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat uiDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    final auth = context.read<AuthProvider>();
    final String role = auth.userData?['role']?.toString().toLowerCase() ?? '';
    final bool isManager = role == 'manager';

    debugPrint('INIT → role=$role isManager=$isManager');

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: isManager ? 0 : 1,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ResignationProvider>();
      provider.fetchMyResignation();

      if (isManager) {
        debugPrint('POST FRAME → fetch manager resignations');
        context.read<ResignationProvider>().fetchAllResignations();
      }
    });
  }

  // ---------------- DATE PICKER ----------------

  void _pickResignationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        resignationDate = picked;
        lastWorkingDate = picked.add(const Duration(days: 90));
      });
    }
  }

  // ---------------- SUBMIT ----------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (resignationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select resignation date')),
      );
      return;
    }

    final provider = context.read<ResignationProvider>();

    final success = await provider.submitResignation(
      resignationDate: apiDateFormat.format(resignationDate!),
      reason: reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resignation submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _readOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: const InputDecoration(
            filled: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ResignationProvider>();

    final bool isManager =
        auth.userData?['role']?.toString().toLowerCase() == 'manager';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resignation'),
        backgroundColor: const Color(0xFF2F9E9E),
      ),
      body: isManager
          ? Column(
              children: [
                _segmentedHeaderTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _managementTab(provider),
                      _userResignationUI(provider, auth),
                    ],
                  ),
                ),
              ],
            )
          : _userResignationUI(provider, auth),
    );
  }

  // ---------------- SEGMENTED HEADER TAB ----------------

  Widget _segmentedHeaderTabs() {
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
            color: const Color(0xFF2F9E9E),
            borderRadius: BorderRadius.circular(25),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black87,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Management'),
            Tab(text: 'My Resignation'),
          ],
        ),
      ),
    );
  }

  // ---------------- MANAGEMENT TAB ----------------

  Widget _managementTab(ResignationProvider provider) {
    if (provider.isLoadingResignations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.allResignations.isEmpty) {
      return const Center(child: Text('No resignations found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.allResignations.length,
      itemBuilder: (_, index) {
        final data = provider.allResignations[index];

        return ResignationDetailsCard(data: data);
      },
    );
  }

  // ---------------- USER RESIGNATION UI ----------------

  Widget _userResignationUI(
    ResignationProvider provider,
    AuthProvider authProvider,
  ) {
    // 1️⃣ Loading
    if (provider.isLoadingMyResignation) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2️⃣ Already submitted → show details
    if (provider.myResignation != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ResignationMyDetailsCard(data: provider.myResignation!),
      );
    }

    // 3️⃣ Not submitted → show apply form
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apply Resignation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _readOnlyField(
                'Employee ID',
                authProvider.userData?['employeeId'] ?? '-',
              ),
              _readOnlyField('Name', authProvider.userData?['username'] ?? '-'),

              const Text('Resignation Date *'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickResignationDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    resignationDate == null
                        ? 'Select date'
                        : uiDateFormat.format(resignationDate!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('Last Working Date *'),
              const SizedBox(height: 6),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  border: const OutlineInputBorder(),
                  hintText: lastWorkingDate == null
                      ? ''
                      : apiDateFormat.format(lastWorkingDate!),
                ),
              ),

              const SizedBox(height: 16),

              const Text('Reason *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: reasonController,
                maxLines: 4,
                validator: (v) => v == null || v.trim().length < 5
                    ? 'Minimum 5 characters required'
                    : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isSubmitting ? null : _submit,
                  child: provider.isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Resignation'),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.description_outlined, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your experience letter will be available for download on your last working day after your resignation is accepted.',
                        style: TextStyle(fontSize: 13),
                      ),
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

  @override
  void dispose() {
    _tabController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}
