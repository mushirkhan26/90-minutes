import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:hrtz_hrms/core/models/chat_message_model.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/socket/socket_provider.dart';
import 'package:hrtz_hrms/core/utils/chat_utils.dart';
import 'package:hrtz_hrms/features/chat/widgtes/document_message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/image_message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/message_bubble.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final VoidCallback _socketListener;
  late final SocketProvider _socketProvider;
  final FileUploadService _fileUploadService = FileUploadService();
  final Uuid _uuid = Uuid();
  final LoggingService _logger = LoggingService.instance;
  bool _isTyping = false;
  bool _isAtBottom = true;
  bool _isLoading = true;
  bool _showGoToBottomButton = false;
  String? _currentDateHeader;

  @override
  void initState() {
    super.initState();
    _socketProvider = context.read<SocketProvider>();
    // Set this chat as active
    _socketProvider.setActiveChatUserId(widget.otherUserId);

    _socketListener = () {
      _logger.info('CHAT_SCREEN', '🔔 SocketProvider listener triggered - messages updated');
      if (mounted) setState(() {});
    };
    _socketProvider.addListener(_socketListener);

    WidgetsBinding.instance.addObserver(this);
    _registerSocketEvents();
    _loadInitialMessages();
    _scrollController.addListener(_handleScroll);
    _messageController.addListener(_handleTyping);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    // Clear active chat
    _socketProvider.setActiveChatUserId(null);

    // Remove listener
    _socketProvider.removeListener(_socketListener);
    // Clear conversation messages from provider memory
    _socketProvider.clearConversationMemory(_generateConversationId(), notify: false);

    super.dispose();
  }

  // 🆕 inside _registerSocketEvents()
  // Add log to see when new message received or socket state updated
  void _registerSocketEvents() {
    _socketProvider.addListener(() {
      _logger.info('CHAT_SCREEN', '🔔 SocketProvider listener triggered - messages updated');
      _logger.info('CHAT_SCREEN', '📥 Total messages now: ${_socketProvider.messages.length}');

      if (mounted) {
        setState(() {});
        if (_isAtBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      }
    });
  }

  // 🆕 inside _loadInitialMessages()
  // Added logs to track what conversationId is loaded and how many messages received
  Future<void> _loadInitialMessages() async {
    setState(() => _isLoading = true);
    final conversationId = _generateConversationId();
    _logger.info('CHAT_SCREEN', '📡 Loading messages for conversationId: $conversationId');

    try {
      await _socketProvider.loadConversationMessages(conversationId);
      final totalMessages = _socketProvider.getConversationMessages(conversationId).length;
      _logger.info('CHAT_SCREEN', '✅ Messages loaded successfully. Count: $totalMessages');
      setState(() => _isLoading = false);
    } catch (e) {
      _logger.error('CHAT_SCREEN', '❌ Failed to load messages', error: e);
      setState(() => _isLoading = false);
    }
  }

  void _handleTyping() {
    if (!_isTyping && _messageController.text.isNotEmpty) {
      setState(() => _isTyping = true);
      _socketProvider.sendTypingStatus(
        userId: widget.currentUserId,
        targetUserId: widget.otherUserId,
        isTyping: true,
      );
    } else if (_isTyping && _messageController.text.isEmpty) {
      setState(() => _isTyping = false);
      _socketProvider.sendTypingStatus(
        userId: widget.currentUserId,
        targetUserId: widget.otherUserId,
        isTyping: false,
      );
    }
  }

  void _handleScroll() {
    if (_scrollController.position.atEdge) {
      final isBottom =
          _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
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

  String _generateConversationId() {
    final sender = widget.currentUserId;
    final receiver = widget.otherUserId;
    return sender.compareTo(receiver) < 0 ? '${sender}_$receiver' : '${receiver}_$sender';
  }

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
          child: Text(headerText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      ),
    );
  }

  // 🆕 inside _sendMessage()
  // Added detailed logs to see exactly what data is being sent to the socket
  Future<void> _sendMessage({String? text, String? fileUrl, String type = 'text'}) async {
    if ((text?.trim().isEmpty ?? true) && fileUrl == null) return;

    final conversationId = _generateConversationId();
    final messageId = _uuid.v4();
    final timestamp = DateTime.now();

    _logger.logNetwork(
      '✉️ Sending message:\n'
      '  conversationId: $conversationId\n'
      '  sender: ${widget.currentUserId}\n'
      '  receiver: ${widget.otherUserId}\n'
      '  type: $type\n'
      '  messageId: $messageId\n'
      '  text: $text\n'
      '  fileUrl: $fileUrl\n'
      '  timestamp: $timestamp',
    );

    await _socketProvider.sendMessage(
      sender: widget.currentUserId,
      senderName: widget.currentUserName,
      receiver: widget.otherUserId,
      text: text ?? '',
      messageId: messageId,
      conversationId: conversationId,
      messageType: type,
      fileUrl: fileUrl,
    );

    _logger.info('CHAT_SCREEN', '✅ Message sent successfully - ID: $messageId');

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final imageUrl = await _fileUploadService.uploadFile(file);
      if (imageUrl != null) {
        await _sendMessage(fileUrl: imageUrl, type: 'image', text: "Image");
      }
    }
  }

  Future<void> _sendDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      final documentUrl = await _fileUploadService.uploadFile(file);
      if (documentUrl != null) {
        await _sendMessage(fileUrl: documentUrl, type: 'document', text: "document");
      }
    }
  }

  void _showMessageOptionsBottomSheet(
    BuildContext context,
    String localMessageId, {
    String? textToCopy,
    bool isMedia = false,
  }) {
    final message = _socketProvider.messages.firstWhere(
      (m) => m.messageId == localMessageId || m.id == localMessageId,
      orElse: () => throw Exception('Message not found'),
    );

    // 👇 always prefer mongoId when doing backend operations
    final backendId = message.id ?? message.messageId;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Choose what to do:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: isMedia ? message.fileUrl! : message.message!),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Unsend Message',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteMessage(backendId!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to unsend this message?'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
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

  // 🆕 inside _deleteMessage()
  // Added logs to track delete request and response
  void _deleteMessage(String backendMessageId) async {
    final conversationId = _generateConversationId();
    _logger.logNetwork(
      '🗑️ Unsend message request:\n'
      '  mongoId: $backendMessageId\n'
      '  conversationId: $conversationId\n'
      '  userId: ${widget.currentUserId}',
    );

    try {
      await _socketProvider.markMessageAsDeleted(
        messageId: backendMessageId, // mongoId
        userId: widget.currentUserId,
        conversationId: conversationId,
      );
      _logger.info('CHAT_SCREEN', '✅ Message unsent successfully - ID: $backendMessageId');

      if (mounted) setState(() {});
    } catch (e) {
      _logger.error('CHAT_SCREEN', '❌ Failed to unsend message', error: e);
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

  void _markMessageAsRead(ChatMessageModel message) async {
    // 👇 only if it's not sent by me, not already read, and we have a mongoId
    final isNotMine = message.sender != widget.currentUserId;
    final isUnread = message.read != true;
    final hasMongoId = message.id != null;

    if (isNotMine && isUnread && hasMongoId) {
      await _socketProvider.markMessageAsRead(messageId: message.id!, userId: widget.currentUserId);
      _logger.logNetwork("👁 Marked message as read [${message.id}]");
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationId = _generateConversationId();
    final conversationMessages = _socketProvider.getConversationMessages(conversationId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Initicon(text: widget.otherUserName, size: 30),
            const SizedBox(width: 8),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Typing indicator
              if (_socketProvider.typingIndicators[widget.otherUserId] == true)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  color: Colors.grey[200],
                  child: Text(
                    "${widget.otherUserName} is typing...",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: conversationMessages.length,
                        itemBuilder: (context, index) {
                          final message = conversationMessages[index];
                          final isMe = message.sender == widget.currentUserId;
                          // 👇 Mark as read when rendering other user's messages
                          if (!isMe) _markMessageAsRead(message);
                          final previousMessage = index > 0
                              ? conversationMessages[index - 1]
                              : null;
                          final showDateHeader =
                              previousMessage == null ||
                              !ChatUtils().isSameDay(previousMessage.timestamp, message.timestamp);
                          return Column(
                            children: [
                              if (showDateHeader) _buildDateHeader(message.timestamp),
                              if (message.messageType == 'text')
                                MessageBubble(
                                  key: ValueKey('chat-msg-$index'),
                                  message: message,
                                  isMe: isMe,
                                  onLongPress: () => _showMessageOptionsBottomSheet(
                                    context,
                                    message.messageId ?? "",
                                    textToCopy: message.message,
                                  ),
                                ),
                              if (message.messageType == 'image')
                                ImageMessageBubble(
                                  key: ValueKey('chat-msg-$index'),
                                  imageUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat('hh:mm a').format(message.timestamp),
                                  read: message.read,
                                  isDeleted: message.isDeleted,
                                  onLongPress: () => _showMessageOptionsBottomSheet(
                                    context,
                                    message.messageId ?? "",
                                    textToCopy: message.fileUrl,
                                    isMedia: true,
                                  ),
                                ),
                              if (message.messageType == 'document')
                                DocumentMessageBubble(
                                  key: ValueKey('chat-msg-$index'),
                                  documentUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat('hh:mm a').format(message.timestamp),
                                  isDeleted: message.isDeleted,
                                  onLongPress: () => _showMessageOptionsBottomSheet(
                                    context,
                                    message.messageId ?? "",
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

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: _sendDocument),
          IconButton(icon: const Icon(Icons.camera_alt), onPressed: _sendImage),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (_) => _sendMessage(text: _messageController.text),
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
}
