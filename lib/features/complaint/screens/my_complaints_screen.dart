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

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintProvider>().fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF4FA3A5), // teal
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "My Complaints",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
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
              label: const Text("Create", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateComplaintBottomSheet(),
                  ),
                );
                if (!mounted) return;
                context.read<ComplaintProvider>().fetchComplaints();
              },
            ),
          )
        ],
      ),

      // 🔹 BODY
      body: Column(
        children: [
          // 🔍 SEARCH BAR
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

          // 🔹 LIST / EMPTY STATE
          Expanded(
            child: Consumer<ComplaintProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.complaints.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 80,
                        color: Colors.teal.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No Complaints for now!!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                }
                final filteredComplaints = provider.complaints.where((c) {
                if (_searchText.isEmpty) return true;

                return c.title.toLowerCase().contains(_searchText) ||
               c.description.toLowerCase().contains(_searchText) ||
               c.id.toLowerCase().contains(_searchText);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    return ComplaintCard(
                      complaint: filteredComplaints[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}