import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/network/mail_service.dart';
import 'package:hrtz_hrms/core/extensions/secure_storage_extension.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/features/mail/provider/mail_provider.dart';
import 'package:hrtz_hrms/features/mail/widgets/mail_tile.dart';
import 'package:provider/provider.dart';
import '../../../config/navigation/app_routes.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  final MailService employeeService = MailService(baseUrl2: ApiHelper.baseUrl2);
  late Future<List<EmployeeModel>> employeeFuture;
  late String employeeID;

  @override
  void initState() {
    super.initState();
  }

  void getData() async {
    employeeID = await context.getCurrentEmployeeId() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFD7D7D7),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primary),
                child: Text("Mail Menu", style: TextStyle(color: Colors.white, fontSize: 22)),
              ),
              ListTile(leading: Icon(Icons.inbox), title: Text("Inbox")),
              ListTile(
                leading: Icon(Icons.send),
                title: Text("Sent"),
                onTap: () {
                  Provider.of<MailProvider>(context).fetchSent(employeeID);
                },
              ),
              ListTile(leading: Icon(Icons.delete), title: Text("Trash")),
            ],
          ),
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                readOnly: true,
                onTap: () {
                  // TODO: handle search focus or open search screen
                },
                decoration: InputDecoration(
                  prefixIcon: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  hintText: "Search mail...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.edit),
          onPressed: () {
            context.pushNamed(AppRoutes.composeMail);
          },
        ),
      ),
    );
  }

  Widget _body() {
    final provider = Provider.of<MailProvider>(context);
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (provider.error != null) {
      return Center(child: Text(provider.error!));
    } else if (provider.inbox.isEmpty) {
      return Center(child: Text('No mails found'));
    } else {
      final mails = provider.inbox;
      return ListView.builder(
        itemCount: mails.length,
        itemBuilder: (c, i) {
          return MailTile(mail: mails[i]);
        },
      );
    }
  }
}
