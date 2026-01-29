import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/core/models/mail_model.dart';
import 'package:hrtz_hrms/features/mail/widgets/mail_drawer.dart';
import 'package:hrtz_hrms/widgets/custom_search_bar.dart';
import 'package:provider/provider.dart';

import '../../../config/navigation/app_routes.dart';
import '../provider/mail_provider.dart';
import '../widgets/mail_tile.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({super.key});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  final mailSearchController = TextEditingController();
  String _selectedFolder = 'Inbox';
  bool _isSelectionMode = false;
  final List<MailModel> _selectedMails = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MailProvider>().fetchInbox();
    });
  }

  Future<void> _handleRefresh(MailProvider provider) async {
    if (_selectedFolder == 'Inbox') {
      await provider.fetchInbox(forceRefresh: true);
    } else if (_selectedFolder == 'Sent') {
      await provider.fetchSent(forceRefresh: true);
    } else if (_selectedFolder == 'Trash') {
      await provider.fetchTrash(forceRefresh: true);
    } else if (_selectedFolder == 'Starred') {
      await provider.fetchStarredMails(forceRefresh: true);
    }
  }

  void _onFolderSelected(String folder) {
    Navigator.pop(context);
    setState(() {
      _selectedFolder = folder;
      _isSelectionMode = false;
      _selectedMails.clear();
      mailSearchController.clear();
    });

    final provider = context.read<MailProvider>();
    provider.setActiveFolder(folder);

    if (folder == 'Inbox') {
      provider.fetchInbox();
    } else if (folder == 'Sent') {
      provider.fetchSent();
    } else if (folder == 'Trash') {
      provider.fetchTrash();
    } else if (folder == 'Starred') {
      provider.fetchStarredMails();
    }
  }

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

  void _enterSelectionMode(MailModel mail) {
    setState(() {
      _isSelectionMode = true;
      _selectedMails.add(mail);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMails.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MailProvider>();
    final mails = provider.displayedMails;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) _exitSelectionMode();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: _isSelectionMode
                ? Text('${_selectedMails.length} selected')
                : Text(_selectedFolder),
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _exitSelectionMode,
                  )
                : null,
            actions: _isSelectionMode
                ? _buildSelectionActions(provider, mails)
                : [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => _handleRefresh(provider),
                    ),
                  ],
          ),
          drawer: _isSelectionMode
              ? null
              : MailDrawer(
                  selectedFolder: _selectedFolder,
                  onFolderSelected: _onFolderSelected,
                ),
          body: Column(
            children: [
              if (!_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: CustomSearchBar(
                    enable: true,
                    controller: mailSearchController,
                    hintText: "Search in $_selectedFolder",
                    onChanged: provider.searchMails,
                  ),
                ),
              if (_selectedFolder == 'Trash' &&
                  !_isSelectionMode &&
                  mails.isNotEmpty)
                if (_selectedFolder == 'Trash' &&
                    !_isSelectionMode &&
                    mails.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.restore_from_trash),
                          label: const Text('Restore All'),
                          onPressed: () => provider.restoreMany(mails),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Empty Trash'),
                          onPressed: provider.deleteAllTrash,
                        ),
                      ],
                    ),
                  ),
              Expanded(
                child: provider.state == MailState.loading
                    ? const Center(child: CircularProgressIndicator())
                    : mails.isEmpty
                    ? const Center(child: Text('No mails found'))
                    : RefreshIndicator(
                        onRefresh: () => _handleRefresh(provider),
                        child: ListView.builder(
                          itemCount: mails.length,
                          itemBuilder: (context, index) {
                            final mail = mails[index];
                            final isSelected = _selectedMails.contains(mail);
                            return GestureDetector(
                              onLongPress: () => _enterSelectionMode(mail),
                              onTap: _isSelectionMode
                                  ? () => _toggleSelection(mail)
                                  : () => context.pushNamed(
                                      AppRoutes.mailDetail,
                                      extra: mail,
                                    ),
                              child: MailTile(
                                mail: mail,
                                isTrash: _selectedFolder == 'Trash',
                                currentUserId: provider
                                    .currentUserId, // ✅ Corrected parameter
                                isSelected: isSelected,
                                isSelectionMode: _isSelectionMode,
                                onToggleSelect: () => _toggleSelection(mail),
                                onMoveToTrash: () =>
                                    provider.moveMailToTrash(mail),
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
          floatingActionButton:
              (!_isSelectionMode && _selectedFolder != 'Trash')
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  onPressed: () => context.pushNamed(AppRoutes.composeMail),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  label: Text(
                    'Compose',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  List<Widget> _buildSelectionActions(
    MailProvider provider,
    List<MailModel> mails,
  ) {
    return [
      IconButton(
        icon: const Icon(Icons.select_all),
        onPressed: () {
          setState(() {
            _selectedMails.clear();
            _selectedMails.addAll(mails);
          });
        },
      ),
      if (_selectedFolder == 'Trash') ...[
        IconButton(
          icon: const Icon(Icons.restore_from_trash),
          onPressed: () {
            provider.restoreMany(_selectedMails);
            _exitSelectionMode();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          onPressed: () {
            for (var m in _selectedMails) {
              provider.deleteMail(m);
            }
            _exitSelectionMode();
          },
        ),
      ] else ...[
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            provider.moveManyToTrash(_selectedMails);
            _exitSelectionMode();
          },
        ),
      ],
    ];
  }
}
