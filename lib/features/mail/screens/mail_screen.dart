import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/config/theme/app_text_styles.dart';
import 'package:hrtz_hrms/core/models/mail_model.dart';
import 'package:hrtz_hrms/features/mail/widgets/mail_drawer.dart';
import 'package:hrtz_hrms/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

import '../../../config/navigation/app_routes.dart';
import '../provider/mail_provider.dart';
import '../widgets/mail_tile.dart';

// class MailScreen extends StatefulWidget {
//   const MailScreen({super.key});

//   @override
//   State<MailScreen> createState() => _MailScreenState();
// }

// class _MailScreenState extends State<MailScreen> {
//   final mailSearchController = TextEditingController();
//   String _selectedFolder = 'Inbox';

//   @override
//   void initState() {
//     super.initState();
//     // ✅ Load cached inbox + refresh if needed
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<MailProvider>();
//     });
//   }

//   Future<void> _handleRefresh(MailProvider provider) async {
//     if (_selectedFolder == 'Inbox') {
//       await provider.fetchInbox(forceRefresh: true);
//     } else if (_selectedFolder == 'Sent') {
//       await provider.fetchSent(forceRefresh: true);
//     } else if (_selectedFolder == 'Trash') {
//       await provider.fetchTrash(forceRefresh: true);
//     }
//   }

//   void _onFolderSelected(String folder) {
//     Navigator.pop(context);
//     setState(() => _selectedFolder = folder);

//     final provider = context.read<MailProvider>();
//     if (folder == 'Inbox') {
//       provider.fetchInbox();
//     } else if (folder == 'Sent') {
//       provider.fetchSent();
//     } else if (folder == 'Trash') {
//       provider.fetchTrash();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<MailProvider>();

//     List<MailModel> mails;
//     switch (_selectedFolder) {
//       case 'Sent':
//         mails = provider.sentMails;
//         break;
//       case 'Trash':
//         mails = provider.trashMails;
//         break;
//       default:
//         mails = provider.inboxMails;
//     }

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           title: Text(_selectedFolder),
//           elevation: 2,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh_rounded),
//               tooltip: "Refresh",
//               onPressed: () => _handleRefresh(provider),
//             ),
//           ],
//         ),
//         // 📬 Drawer extracted into a new widget
//         drawer: MailDrawer(selectedFolder: _selectedFolder, onFolderSelected: _onFolderSelected),
//         body: Column(
//           children: [
//             // 🔍 Search bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               child: CustomSearchBar(
//                 enable: true,
//                 controller: mailSearchController,
//                 hintText: "Search mails here",
//                 onChanged: provider.searchMails,
//               ),
//             ),

//             // 📩 Mail List
//             Expanded(
//               child: provider.state == MailState.loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : mails.isEmpty
//                   ? const Center(child: Text('No mails found'))
//                   : RefreshIndicator(
//                       onRefresh: () => _handleRefresh(provider),
//                       child: ListView.builder(
//                         padding: const EdgeInsets.symmetric(vertical: 6),
//                         itemCount: mails.length,
//                         itemBuilder: (context, index) {
//                           final mail = mails[index];
//                           return MailTile(
//                             mail: mail,
//                             isTrash: _selectedFolder == 'Trash',
//                             onMoveToTrash: () => provider.moveMailToTrash(mail),
//                             onRestore: () => provider.restoreMail(mail),
//                             onDelete: () => provider.deleteMail(mail),
//                           );
//                         },
//                       ),
//                     ),
//             ),
//           ],
//         ),

//         floatingActionButton: FloatingActionButton.extended(
//           backgroundColor: AppColors.primary,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
//           elevation: 6,
//           onPressed: () => context.pushNamed(AppRoutes.composeMail),
//           icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
//           label: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 4.0),
//             child: Text('Compose', style: AppTextStyles.black12_400.copyWith(color: Colors.white)),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  final mailSearchController = TextEditingController();

  // 🗂️ Currently selected folder
  String _selectedFolder = 'Inbox';

  // ✅ Selection mode flags
  bool _isSelectionMode = false;
  final List<MailModel> _selectedMails = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MailProvider>();
    });
  }

  /// 🔄 Handle pull-to-refresh
  Future<void> _handleRefresh(MailProvider provider) async {
    if (_selectedFolder == 'Inbox') {
      await provider.fetchInbox(forceRefresh: true);
    } else if (_selectedFolder == 'Sent') {
      await provider.fetchSent(forceRefresh: true);
    } else if (_selectedFolder == 'Trash') {
      await provider.fetchTrash(forceRefresh: true);
    }
  }

  /// 📁 Change folder from drawer
  void _onFolderSelected(String folder) {
    Navigator.pop(context);
    setState(() {
      _selectedFolder = folder;
      _isSelectionMode = false;
      _selectedMails.clear();
    });

    final provider = context.read<MailProvider>();
    if (folder == 'Inbox') {
      provider.fetchInbox();
    } else if (folder == 'Sent') {
      provider.fetchSent();
    } else if (folder == 'Trash') {
      provider.fetchTrash();
    }
  }

  /// 🟩 Toggle single mail selection
  void _toggleSelection(MailModel mail) {
    setState(() {
      if (_selectedMails.contains(mail)) {
        _selectedMails.remove(mail);
        if (_selectedMails.isEmpty) _isSelectionMode = false;
      } else {
        _selectedMails.add(mail);
      }
    });
  }

  /// 🔵 Enter selection mode on long press
  void _enterSelectionMode(MailModel mail) {
    setState(() {
      _isSelectionMode = true;
      _selectedMails.add(mail);
    });
  }

  /// ❌ Exit selection mode
  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMails.clear();
    });
  }

  /// ✅ Select all mails
  void _selectAll(List<MailModel> mails) {
    setState(() {
      _selectedMails.clear();
      _selectedMails.addAll(mails);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MailProvider>();

    // 📨 Pick mails based on current folder
    List<MailModel> mails;
    switch (_selectedFolder) {
      case 'Sent':
        mails = provider.sentMails;
        break;
      case 'Trash':
        mails = provider.trashMails;
        break;
      default:
        mails = provider.inboxMails;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isSelectionMode) {
          _exitSelectionMode();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[100],

          // 🧭 AppBar with selection / normal modes
          appBar: AppBar(
            title: _isSelectionMode
                ? Text('${_selectedMails.length} selected')
                : Text(_selectedFolder),
            elevation: 2,
            leading: _isSelectionMode
                ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelectionMode)
                : null,
            actions: _isSelectionMode
                ? _buildSelectionActions(provider, mails)
                : [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: "Refresh",
                      onPressed: () => _handleRefresh(provider),
                    ),
                  ],
          ),

          // 🗂️ Drawer (hidden in selection mode)
          drawer: _isSelectionMode
              ? null
              : MailDrawer(selectedFolder: _selectedFolder, onFolderSelected: _onFolderSelected),

          body: Column(
            children: [
              // 🔍 Search bar (only in normal mode)
              if (!_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: CustomSearchBar(
                    enable: true,
                    controller: mailSearchController,
                    hintText: "Search mails here",
                    onChanged: provider.searchMails,
                  ),
                ),

              // ♻ Trash folder actions
              if (_selectedFolder == 'Trash' && !_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.restore_from_trash),
                        label: const Text('Restore All'),
                        onPressed: () => provider.restoreMany(provider.trashMails),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Empty Trash'),
                        onPressed: provider.deleteAllTrash,
                      ),
                    ],
                  ),
                ),

              // 📬 Mail list
              Expanded(
                child: provider.state == MailState.loading
                    ? const Center(child: CircularProgressIndicator())
                    : mails.isEmpty
                    ? const Center(child: Text('No mails found'))
                    : RefreshIndicator(
                        onRefresh: () => _handleRefresh(provider),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: mails.length,
                          itemBuilder: (context, index) {
                            final mail = mails[index];
                            final isSelected = _selectedMails.contains(mail);

                            return GestureDetector(
                              onLongPress: () => _enterSelectionMode(mail),
                              onTap: _isSelectionMode
                                  ? () => _toggleSelection(mail)
                                  : () => context.pushNamed(AppRoutes.mailDetail, extra: mail),
                              child: MailTile(
                                mail: mail,
                                isTrash: _selectedFolder == 'Trash',
                                isSelected: isSelected,
                                isSelectionMode: _isSelectionMode,
                                onToggleSelect: () => _toggleSelection(mail),
                                onMoveToTrash: () => provider.moveMailToTrash(mail),
                                onRestore: () => provider.restoreMail(mail),
                                onDelete: () => provider.deleteMail(mail),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),

          // 📝 Floating compose button
          floatingActionButton: (!_isSelectionMode && _selectedFolder != 'Trash')
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 6,
                  onPressed: () => context.pushNamed(AppRoutes.composeMail),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Compose',
                      style: AppTextStyles.black12_400.copyWith(color: Colors.white),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// 🧰 AppBar actions when selection mode is active
  List<Widget> _buildSelectionActions(MailProvider provider, List<MailModel> mails) {
    return [
      // ✅ Select All button
      IconButton(
        icon: const Icon(Icons.select_all),
        tooltip: "Select All",
        onPressed: () => _selectAll(mails),
      ),
      const SizedBox(width: 4),

      if (_selectedFolder == 'Trash') ...[
        IconButton(
          icon: const Icon(Icons.restore_from_trash),
          tooltip: "Restore selected",
          onPressed: () {
            provider.restoreMany(_selectedMails);
            _exitSelectionMode();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          tooltip: "Delete selected",
          onPressed: () {
            for (final mail in _selectedMails) {
              provider.deleteMail(mail);
            }
            _exitSelectionMode();
          },
        ),
      ] else ...[
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: "Move to Trash",
          onPressed: () {
            provider.moveManyToTrash(_selectedMails);
            _exitSelectionMode();
          },
        ),
      ],
    ];
  }
}
