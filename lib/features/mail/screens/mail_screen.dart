import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/core/extensions/secure_storage_extension.dart';
import 'package:provider/provider.dart';

import '../../../config/navigation/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/api/base_api/api_helper.dart';
import '../../../core/api/network/mail_service.dart';
import '../../../core/models/employee_model.dart';
import '../provider/mail_provider.dart';
import '../widgets/mail_tile.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  final MailService employeeService = MailService(baseUrl2: ApiHelper.baseUrl2);
  late Future<List<EmployeeModel>> employeeFuture;
  late String employeeID;
  String selectedMailbox = 'Inbox';

  void getData() async {
    employeeID = await context.getCurrentEmployeeId() ?? '';
  }

  @override
  void initState() {
    super.initState();
    getData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MailProvider>(context, listen: false).fetchInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title: Text(selectedMailbox)),
        backgroundColor: const Color(0xFFD7D7D7),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primary),
                child: Text("Mail Menu", style: TextStyle(color: Colors.white, fontSize: 22)),
              ),
              ListTile(
                leading: const Icon(Icons.inbox),
                title: const Text("Inbox"),
                selected: selectedMailbox == 'Inbox',
                onTap: () {
                  setState(() {
                    selectedMailbox = 'Inbox';
                  });
                  Provider.of<MailProvider>(context, listen: false).fetchInbox();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text("Sent"),
                selected: selectedMailbox == 'Sent',
                onTap: () {
                  setState(() {
                    selectedMailbox = 'Sent';
                  });
                  Provider.of<MailProvider>(context, listen: false).fetchSent(employeeID);
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Trash"),
                selected: selectedMailbox == 'Trash',
                onTap: () {
                  setState(() {
                    selectedMailbox = 'Trash';
                  });
                  Provider.of<MailProvider>(context, listen: false).moveToTrash(employeeID);
                  Navigator.pop(context);
                },
              ),
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
            Expanded(
              child: Consumer<MailProvider>(
                builder: (context, provider, child) {
                  return _body(provider);
                },
              ),
            ),
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

  Widget _body(MailProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provider.error != null) {
      return Center(child: Text(provider.error!));
    } else {
      final mails = selectedMailbox == 'Inbox'
          ? provider.inbox
          : selectedMailbox == 'Sent'
          ? provider.sent
          : provider.trash;
      if (mails.isEmpty) {
        return const Center(child: Text('No mails found'));
      } else {
        return ListView.builder(
          itemCount: mails.length,
          itemBuilder: (context, index) {
            final mail = mails[index];
            return MailTile(
              mail: mail,
              isTrash: selectedMailbox == 'Trash',
              onMoveToTrash: () async {
                final provider = Provider.of<MailProvider>(context, listen: false);
                final success = await provider.moveToTrash(mail.id ?? '');
                if (success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Mail moved to trash")));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Failed to move mail to trash")));
                }
              },
              onRestore: () async {
                final provider = Provider.of<MailProvider>(context, listen: false);
                await provider.restoreFromTrash(mail.id ?? '');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Mail restored from trash")));
              },

              onDelete: () async {
                if (mail.id == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Mail ID is missing")));
                  return;
                }
                final provider = Provider.of<MailProvider>(context, listen: false);
                final success = await provider.deleteMail(mail.id!);
                if (success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Mail deleted permanently")));
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Failed to delete mail")));
                }
              },
            );
          },
        );
      }
    }
  }
}
