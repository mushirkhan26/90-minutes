import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/core/models/employee_model.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';
import 'package:hrtz_hrms/core/extensions/secure_storage_extension.dart';
import 'package:hrtz_hrms/core/socket/group_socket_provider.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GroupDetailsScreen extends StatefulWidget {
  final GroupChatModel group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  String? _currentUserId;
  List<EmployeeModel> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadEmployees();
  }

  Future<void> _loadUser() async {
    _currentUserId = await context.getCurrentEmployeeId();
    setState(() {});
  }

  Future<void> _loadEmployees() async {
    final list = await LocalStorageService().getEmployeeList();
    if (list != null) {
      setState(() {
        _employees = list;
      });
    }
  }

  // ================= EDIT GROUP NAME =================

  Future<void> _editGroupName(
      GroupSocketProvider provider,
      GroupChatModel group) async {

    final controller =
        TextEditingController(text: group.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Group Name"),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: "Enter group name"),
        ),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, controller.text),
              child: const Text("Save")),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await provider.editGroupName(
        group.groupId,
        newName,
        _currentUserId ?? '',
      );
    }
  }

  // ================= ADD MEMBER =================

  Future<void> _addMember(
      GroupSocketProvider provider,
      GroupChatModel group) async {

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: _employees
              .where((emp) =>
                  !group.members.contains(emp.employeeID))
              .map((emp) => ListTile(
                    title: Text(emp.name),
                    subtitle: Text(emp.employeeID),
                    onTap: () async {
                      Navigator.pop(context);

                      await provider.addGroupMembers(
                        group.groupId,
                        [emp.employeeID],
                        _currentUserId ?? '',
                      );
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  // ================= PROFILE EDIT =================

  Future<void> _editProfile(
    GroupSocketProvider provider,
    GroupChatModel group) async {

  final picker = ImagePicker();

  final pickedFile =
      await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return;

  final imageFile = File(pickedFile.path);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final uploadService = FileUploadService();
  final uploadedUrl =
      await uploadService.uploadFile(imageFile);
      if(!mounted) return;

  Navigator.pop(context); // remove loader

  if (uploadedUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Image upload failed"),
      ),
    );
    return;
  }

  await provider.updateGroupIcon(
    groupId: group.groupId,
    iconUrl: uploadedUrl,
    updatedBy: _currentUserId ?? '',
  );
  if(!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Group icon updated successfully"),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupSocketProvider>();

    final group = provider.groupChats.firstWhere(
      (g) => g.groupId == widget.group.groupId,
      orElse: () => widget.group,
    );

    final isCreator = group.createdBy == _currentUserId;
    final isGroupAdmin = group.admins.contains(_currentUserId);

    return Scaffold(
      appBar: AppBar(title: const Text("Group Info")),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 20),

            // ================= PROFILE =================

            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
  radius: 50,
  backgroundImage: group.icon != null &&
          group.icon!.isNotEmpty
      ? NetworkImage(group.icon!)
      : null,
  backgroundColor: Colors.blueGrey,
  child: group.icon == null ||
          group.icon!.isEmpty
      ? const Icon(Icons.group,
          size: 40,
          color: Colors.white)
      : null,
),
                if (isGroupAdmin)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit,
                          size: 18, color: Colors.white),
                      onPressed: () => _editProfile(provider, group),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 12),

            // ================= GROUP NAME =================

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                if (isGroupAdmin)
                  GestureDetector(
                    onTap: () =>
                        _editGroupName(provider, group),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.edit, size: 18),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              "${group.members.length} members",
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // ================= ADMIN ONLY =================

            if (isGroupAdmin)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title:
                          const Text("Admin Only Messaging"),
                      subtitle: const Text(
                          "Only admins can send messages"),
                      value: group.adminOnlyMessaging,
                      onChanged: (value) async {
                        await provider
                            .toggleAdminOnlyMessaging(
                          groupId: group.groupId,
                          value: value,
                          userId:
                              _currentUserId ?? '',
                        );
                      },
                    ),

                    if (group.adminOnlyMessaging)
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Group is locked. Only admins can send messages.",
                          style: TextStyle(
                              color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),

            const Divider(),

            // ================= MEMBERS HEADER =================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Members",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  if (isGroupAdmin)
                    ElevatedButton.icon(
  onPressed: () => _addMember(provider, group),
  icon: const Icon(
    Icons.person_add,
    color: Colors.white,
  ),
  label: const Text(
    "Add",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,   
    foregroundColor: Colors.white,  
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  ),
)
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= MEMBER LIST =================

            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: group.members.length,
              itemBuilder: (context, index) {
                final memberId =
                    group.members[index];

                final emp =
                    _employees.firstWhere(
                  (e) =>
                      e.employeeID ==
                      memberId,
                  orElse: () => EmployeeModel(
                      employeeID:
                          memberId,
                      name: memberId),
                );

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      emp.name.isNotEmpty
                          ? emp.name[0]
                          : "?",
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(emp.name),

                      if (group.createdBy ==
                          memberId)
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 6),
                          child: Text(
                            "Creator",
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.orange),
                          ),
                        ),

                      if (group.admins
                              .contains(memberId) &&
                          group.createdBy !=
                              memberId)
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 6),
                          child: Text(
                            "Admin",
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.blue),
                          ),
                        ),
                    ],
                  ),
                  subtitle:
                      Text(memberId),

                  trailing: isGroupAdmin &&
                          memberId !=
                              _currentUserId
                      ? PopupMenuButton<String>(
                          onSelected: (val) async {
                            if (val ==
                                "make_admin") {
                              await provider
                                  .makeGroupAdmin(
                                groupId:
                                    group.groupId,
                                userId:
                                    memberId,
                                updatedBy:
                                    _currentUserId ??
                                        '',
                              );
                            } else if (val ==
                                "remove_admin") {
                              await provider
                                  .removeGroupAdmin(
                                groupId:
                                    group.groupId,
                                userId:
                                    memberId,
                                updatedBy:
                                    _currentUserId ??
                                        '',
                              );
                            } else if (val ==
                                "remove") {
                              await provider
                                  .removeGroupMember(
                                group.groupId,
                                memberId,
                                _currentUserId ??
                                    '',
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            if (!group.admins
                                .contains(memberId))
                              const PopupMenuItem(
                                value:
                                    "make_admin",
                                child: Text(
                                    "Make Admin"),
                              ),
                            if (group.admins
                                .contains(memberId))
                              const PopupMenuItem(
                                value:
                                    "remove_admin",
                                child: Text(
                                    "Remove Admin"),
                              ),
                            const PopupMenuItem(
                              value: "remove",
                              child: Text(
                                  "Remove from Group"),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),

            const SizedBox(height: 20),

            if (isCreator)
              ListTile(
                leading: const Icon(
                    Icons.delete,
                    color: Colors.red),
                title:
                    const Text("Delete Group"),
                onTap: () async {
                  await provider.deleteGroup(
                    groupId:
                        group.groupId,
                    deletedBy:
                        _currentUserId ??
                            '',
                  );
                  Navigator.pop(context);
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}