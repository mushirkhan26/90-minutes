// lib/screens/group_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:hrtz_hrms/config/navigation/app_router.dart';
import 'package:hrtz_hrms/config/theme/app_colors.dart';
import 'package:hrtz_hrms/config/theme/app_text_styles.dart';
import 'package:hrtz_hrms/core/models/group_chat_list_model.dart';
import 'package:hrtz_hrms/core/models/group_message_model.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/socket/group_socket_provider.dart';
import 'package:hrtz_hrms/features/chat/widgtes/document_message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/group_message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/image_message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/voice_message_bubble.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;
  final String currentUserName;
  final GroupChatModel? groupModel;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
    required this.currentUserName,
    this.groupModel,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late GroupSocketProvider _groupSocketProvider;
  final FileUploadService _fileUploadService = FileUploadService();

  final LoggingService _logger = LoggingService.instance;
  bool _isTyping = false;
  bool _isAtBottom = true;
  bool _isLoading = true;
  bool _showGoToBottomButton = false;
  String? _currentDateHeader;

  @override
  void initState() {
    super.initState();
    _groupSocketProvider = context.read<GroupSocketProvider>();
    // Set this group as active
    _groupSocketProvider.setActiveGroupId(widget.groupId);
    // Reset unread count for this group
    _groupSocketProvider.resetGroupUnreadCount(widget.groupId, notify: true);
    // Register socket events
    _registerSocketEvents();
    // Load initial messages
    _loadInitialMessages();
    // Add scroll and typing listeners
    _scrollController.addListener(_handleScroll);
    _messageController.addListener(_handleTyping);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    // Clear active group
    _groupSocketProvider.setActiveGroupId(null);
    super.dispose();
  }

  /// Registers socket event listeners for group chat updates.
  void _registerSocketEvents() {
    _groupSocketProvider.addListener(() {
      _logger.info(
        'GROUP_CHAT_SCREEN',
        '🔔 GroupSocketProvider listener triggered - messages updated',
      );
      if (!mounted) return;
      setState(() {});
      if (_isAtBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  /// Loads initial group messages from local storage.
  Future<void> _loadInitialMessages() async {
    setState(() => _isLoading = true);
    _logger.info(
      'GROUP_CHAT_SCREEN',
      '📡 Loading messages for group: ${widget.groupId}',
    );
    try {
      await _groupSocketProvider.loadGroupMessages(widget.groupId);
      _logger.info('GROUP_CHAT_SCREEN', '✅ Messages loaded successfully');
      setState(() => _isLoading = false);
    } catch (e) {
      _logger.error('GROUP_CHAT_SCREEN', '❌ Failed to load messages', error: e);
      setState(() => _isLoading = false);
    }
  }

  /// Handles typing status updates.
  void _handleTyping() {
    if (!_isTyping && _messageController.text.isNotEmpty) {
      setState(() => _isTyping = true);
      _groupSocketProvider.sendGroupTypingStatus(
        userId: widget.currentUserId,
        userName: widget.currentUserName,
        groupId: widget.groupId,
        isTyping: true,
      );
    } else if (_isTyping && _messageController.text.isEmpty) {
      setState(() => _isTyping = false);
      _groupSocketProvider.sendGroupTypingStatus(
        userId: widget.currentUserId,
        userName: widget.currentUserName,
        groupId: widget.groupId,
        isTyping: false,
      );
    }
  }

  /// Handles scroll events to show/hide the "go to bottom" button.
  void _handleScroll() {
    if (_scrollController.position.atEdge) {
      final isBottom =
          _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (isBottom != _isAtBottom) {
        setState(() => _isAtBottom = isBottom);
      }
    }
    if (!_isAtBottom && !_showGoToBottomButton) {
      setState(() => _showGoToBottomButton = true);
    } else if (_isAtBottom && _showGoToBottomButton) {
      setState(() => _showGoToBottomButton = false);
    }
  }

  /// Scrolls the chat to the bottom.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Formats a date into a header string (e.g., "Today", "Yesterday").
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Builds a date header widget for the chat.
  Widget _buildDateHeader(DateTime date) {
    final headerText = _formatDateHeader(date);
    if (_currentDateHeader == headerText) {
      return const SizedBox.shrink();
    }
    _currentDateHeader = headerText;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            headerText,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Sends a text, image, or document message.
  Future<void> _sendMessage({
    String? text,
    String? fileUrl,
    String? fileName,
    String type = 'text',
  }) async {
    if ((text?.trim().isEmpty ?? true) && fileUrl == null) return;
    final messageId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // ✅ CLEAR INPUT + SCROLL
      _messageController.clear();
      _scrollToBottom();

      // ✅ SEND TO SOCKET (BACKEND)
      await _groupSocketProvider.sendGroupMessage(
        groupId: widget.groupId,
        sender: widget.currentUserId,
        senderName: widget.currentUserName,
        text: text ?? '',
        messageId: messageId,
        messageType: type,
        fileUrl: fileUrl,
        fileName: fileName,
      );

      _logger.info(
        'GROUP_CHAT_SCREEN',
        '🚀 Socket emit success (group message)',
      );
    } catch (e, st) {
      _logger.error(
        'GROUP_CHAT_SCREEN',
        '❌ Failed to send group message',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Opens the image picker and sends the selected image.
  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final imageUrl = await _fileUploadService.uploadFile(file);
      if (imageUrl != null) {
        await _sendMessage(fileUrl: imageUrl, type: 'image', text: "image");
      }
    }
  }

  /// Opens the file picker and sends the selected document.
  Future<void> _sendDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );
    if (result != null) {
      final picked = result.files.first;
      final file = File(result.files.single.path!);
      final documentUrl = await _fileUploadService.uploadFile(file);
      if (documentUrl != null) {
        await _sendMessage(
          fileUrl: documentUrl,
          fileName: picked.name,
          type: 'document',
          text: "document",
        );
      }
    }
  }

  // /// Records and sends a voice message.
  // Future<void> _sendVoiceMessage() async {
  //   // Placeholder: Implement voice recording logic
  //   // For example, use a package like `sound_record` or `audioplayers`
  //   // After recording, upload the voice file and send the URL
  //   final voiceUrl = await _recordAndUploadVoice();
  //   if (voiceUrl != null) {
  //     await _sendMessage(fileUrl: voiceUrl, type: 'voice');
  //   }
  // }

  // /// Placeholder for voice recording and upload logic.
  // Future<String?> _recordAndUploadVoice() async {
  //   // Implement voice recording and upload logic here
  //   // Return the URL of the uploaded voice file
  //   return null;
  // }

  /// Shows a bottom sheet with message options (copy, delete, etc.).
  void _showMessageOptionsBottomSheet(
    BuildContext context,
    String localMessageId, {
    String? textToCopy,
    bool isMedia = false,
  }) {
    final message = _groupSocketProvider.groupMessages.firstWhere(
      (m) => m.messageId == localMessageId || m.id == localMessageId,
      orElse: () => throw Exception('Message not found'),
    );
    final messageIdForAction = message.id != null
        ? message.id!
        : message.messageId;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Choose what to do:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.clear_rounded),
                    ),
                  ],
                ),
              ),
              if (textToCopy != null || (isMedia && message.fileUrl != null))
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: Text(
                    isMedia ? 'Copy Media URL' : 'Copy Message',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: isMedia ? message.fileUrl! : message.text,
                      ),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              if (message.sender == widget.currentUserId)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Unsend Message',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteMessage(messageIdForAction);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog before deleting a message.
  void _confirmDeleteMessage(String messageId) {
    if (messageId.startsWith('temp_')) {
      // Local message ni delete cheyali ante direct ga provider nundi delete chey
      _groupSocketProvider.removeLocalGroupMessage(messageId);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to unsend this message?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Unsend', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMessage(messageId);
              },
            ),
          ],
        );
      },
    );
  }

  /// Deletes a message from the group chat.
  void _deleteMessage(String backendMessageId) async {
    _logger.logNetwork(
      '🗑️ Unsend group message request:\n'
      '  messageId: $backendMessageId\n'
      '  groupId: ${widget.groupId}\n'
      '  userId: ${widget.currentUserId}',
    );
    try {
      await _groupSocketProvider.deleteGroupMessage(
        messageId: backendMessageId,
        userId: widget.currentUserId,
        groupId: widget.groupId,
      );
      _logger.info(
        'GROUP_CHAT_SCREEN',
        '✅ Message unsent successfully - ID: $backendMessageId',
      );
      if (mounted) setState(() {});
    } catch (e) {
      _logger.error(
        'GROUP_CHAT_SCREEN',
        '❌ Failed to unsend message',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unsend message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Marks a message as read if it's from another user.
  void _markMessageAsRead(GroupMessageModel message) async {
    final isNotMine = message.sender != widget.currentUserId;
    final isUnread = message.read != true;
    final hasMongoId = message.id != null;
    if (isNotMine && isUnread && hasMongoId) {
      await _groupSocketProvider.markGroupMessageAsRead(
        messageId: message.id!,
        userId: widget.currentUserId,
      );
      _logger.logNetwork("👁 Marked group message as read [${message.id}]");
    }
  }

  /// Checks if two dates are on the same day.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Builds the input field for sending messages.
  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _sendDocument,
          ),
          IconButton(icon: const Icon(Icons.camera_alt), onPressed: _sendImage),
          //IconButton(icon: const Icon(Icons.mic), onPressed: _sendVoiceMessage),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              // onSubmitted: (_) => _sendMessage(text: _messageController.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(text: _messageController.text),
          ),
        ],
      ),
    );
  }

  // clear group chat
  Future<void> _clearChat() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text(
          'This will clear all messages in this group for you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      try {
        setState(() => _isLoading = true);
        await _groupSocketProvider.clearGroupChat(
          groupId: widget.groupId,
          userId: widget.currentUserId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat cleared successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear chat: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupMessages = _groupSocketProvider.getGroupMessages(widget.groupId);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.background,
        backgroundColor: AppColors.background,
        elevation: 1,
        title: GestureDetector(
          onTap: () {
            if (widget.groupModel != null) {
              // Navigate to GroupDetailsScreen
              context.goToGroupDetails(group: widget.groupModel!);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.groupName, style: AppTextStyles.black16_500),
              Text("Tap here to see details", style: AppTextStyles.grey12_600),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_chat') {
                _clearChat();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'clear_chat',
                child: Text('Clear Chat'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Typing indicator for group chat
              if (_groupSocketProvider.groupTypingIndicators.containsKey(
                    '${widget.groupId}_${widget.currentUserId}',
                  ) &&
                  _groupSocketProvider
                          .groupTypingIndicators['${widget.groupId}_${widget.currentUserId}'] ==
                      true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  color: Colors.grey[200],
                  child: const Text(
                    "Someone is typing...",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: groupMessages.length,
                        itemBuilder: (context, index) {
                          final message = groupMessages[index];
                          final isMe = message.sender == widget.currentUserId;
                          if (!isMe) _markMessageAsRead(message);
                          final previousMessage = index > 0
                              ? groupMessages[index - 1]
                              : null;
                          final showDateHeader =
                              previousMessage == null ||
                              !_isSameDay(
                                previousMessage.timestamp,
                                message.timestamp,
                              );
                          return Column(
                            children: [
                              if (showDateHeader)
                                _buildDateHeader(message.timestamp),
                              if (message.messageType == 'text')
                                GroupMessageBubble(
                                  key: ValueKey('group-msg-$index'),
                                  message: message,
                                  isMe: isMe,
                                  onLongPress: () =>
                                      _showMessageOptionsBottomSheet(
                                        context,
                                        message.messageId,
                                        textToCopy: message.text,
                                      ),
                                ),
                              if (message.messageType == 'image')
                                ImageMessageBubble(
                                  key: ValueKey('group-msg-$index'),
                                  imageUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat(
                                    'hh:mm a',
                                  ).format(message.timestamp),
                                  read: message.read,
                                  isDeleted: message.isDeleted,
                                  onLongPress: () =>
                                      _showMessageOptionsBottomSheet(
                                        context,
                                        message.messageId,
                                        textToCopy: message.fileUrl,
                                        isMedia: true,
                                      ),
                                ),
                              if (message.messageType == 'document')
                                DocumentMessageBubble(
                                  key: ValueKey('group-msg-$index'),
                                  documentUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat(
                                    'hh:mm a',
                                  ).format(message.timestamp),
                                  isDeleted: message.isDeleted,
                                  onLongPress: () =>
                                      _showMessageOptionsBottomSheet(
                                        context,
                                        message.messageId,
                                        textToCopy: message.fileUrl,
                                        isMedia: true,
                                      ),
                                ),
                              if (message.messageType == 'voice')
                                VoiceMessageBubble(
                                  key: ValueKey('group-msg-$index'),
                                  voiceUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat(
                                    'hh:mm a',
                                  ).format(message.timestamp),
                                  isDeleted: message.isDeleted,
                                  onLongPress: () =>
                                      _showMessageOptionsBottomSheet(
                                        context,
                                        message.messageId,
                                        textToCopy: message.fileUrl,
                                        isMedia: true,
                                      ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
              _buildInputField(),
            ],
          ),
          if (_showGoToBottomButton)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward),
              ),
            ),
        ],
      ),
    );
  }
}
