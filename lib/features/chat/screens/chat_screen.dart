import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:hrtz_hrms/core/models/chat_message_model.dart';
import 'package:hrtz_hrms/core/services/file_upload_service.dart';
import 'package:hrtz_hrms/core/socket/socket_provider.dart';
import 'package:hrtz_hrms/core/utils/chat_utils.dart';
import 'package:hrtz_hrms/features/chat/widgtes/document_message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/image_message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/message_bubble.dart';
import 'package:hrtz_hrms/features/chat/widgtes/voice_message_bubble.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  final SocketProvider _socketProvider;
  final FileUploadService _fileUploadService = FileUploadService();
  // final Uuid _uuid = Uuid();
  bool _isTyping = false;
  bool _isAtBottom = true;
  bool _isLoading = true;
  bool _showGoToBottomButton = false;
  String? _currentDateHeader;
  final Map<Key, GlobalKey> _messageKeys = {};

  _ChatScreenState() : _socketProvider = SocketProvider();

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _registerSocketEvents() {
    _socketProvider.addListener(_onSocketUpdate);
  }

  void _onSocketUpdate() {
    if (mounted) setState(() {});
  }

  void _loadInitialMessages() {
    // TODO: Load previous messages from local storage or API
    setState(() {
      _isLoading = false;
    });
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

  Future<void> _sendMessage({String? text, String? fileUrl, String type = 'text'}) async {
    if ((text?.trim().isEmpty ?? true) && fileUrl == null) return;

    final conversationId = _generateConversationId();
    // final messageId = _uuid.v4();

    await _socketProvider.sendMessage(
      sender: widget.currentUserId,
      senderName: widget.currentUserName,
      receiver: widget.otherUserId,
      text: text ?? '',
      conversationId: conversationId,
      messageType: type,
      fileUrl: fileUrl,
    );

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
        await _sendMessage(fileUrl: imageUrl, type: 'image');
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
        await _sendMessage(fileUrl: documentUrl, type: 'document');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Initicon(text: widget.otherUserName, size: 30),
            const SizedBox(width: 8),
            Text(widget.otherUserName),
          ],
        ),
        actions: [
          //IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          //IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
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
                        itemCount: _socketProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = _socketProvider.messages[index];
                          final isMe = message.sender == widget.currentUserId;
                          final previousMessage = index > 0
                              ? _socketProvider.messages[index - 1]
                              : null;

                          final showDateHeader =
                              previousMessage == null ||
                              !ChatUtils().isSameDay(previousMessage.timestamp, message.timestamp);

                          final valueKey = ValueKey('chat-msg-$index');
                          final globalKey = GlobalKey();
                          _messageKeys[valueKey] = globalKey;

                          return Column(
                            children: [
                              if (showDateHeader) _buildDateHeader(message.timestamp),
                              if (message.messageType == 'text')
                                MessageBubble(
                                  key: valueKey,
                                  message: ChatMessageModel(
                                    message: message.message,
                                    timestamp: message.timestamp,
                                    sender: message.sender,
                                    read: message.read,
                                    isDeleted: message.isDeleted,
                                    messageId: message.messageId,
                                  ),
                                  isMe: isMe,
                                  onLongPress: () => _deleteMessage(message.messageId ?? ""),
                                ),
                              if (message.messageType == 'image')
                                ImageMessageBubble(
                                  key: valueKey,
                                  imageUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat('hh:mm a').format(message.timestamp),
                                  read: message.read,
                                  isDeleted: message.isDeleted,
                                  onLongPress: () => _deleteMessage(message.messageId ?? ""),
                                ),
                              if (message.messageType == 'document')
                                DocumentMessageBubble(
                                  key: valueKey,
                                  documentUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat('hh:mm a').format(message.timestamp),
                                  isDeleted: message.isDeleted,
                                  onLongPress: () => _deleteMessage(message.messageId ?? ""),
                                ),
                              if (message.messageType == 'voice')
                                VoiceMessageBubble(
                                  key: valueKey,
                                  voiceUrl: message.fileUrl!,
                                  isMe: isMe,
                                  timestamp: DateFormat('hh:mm a').format(message.timestamp),
                                  isDeleted: message.isDeleted,
                                  onLongPress: () => _deleteMessage(message.messageId ?? ""),
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

  void _deleteMessage(String messageId) {
    _socketProvider.deleteMessage(
      messageId: messageId,
      userId: widget.currentUserId,
      conversationId: _generateConversationId(),
    );
  }
}
