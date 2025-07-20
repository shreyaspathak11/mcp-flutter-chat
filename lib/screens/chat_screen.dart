import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonAnimationController,
      curve: Curves.elasticOut,
    ));

    // Auto-connect to chat service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().connect();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _sendButtonAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<ChatService>().sendMessage(message);
    _messageController.clear();

    // Animate send button
    _sendButtonAnimationController.forward().then((_) {
      _sendButtonAnimationController.reverse();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatService>(
          builder: (context, chatService, child) {
            return Column(
              children: [
                const Text('MCP Chat'),
                Text(
                  chatService.connectionStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: chatService.isConnectedToServer
                            ? Colors.green
                            : Colors.orange,
                      ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          Consumer<ChatService>(
            builder: (context, chatService, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      chatService.clearHistory();
                      break;
                    case 'reconnect':
                      chatService.disconnect();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        chatService.connect();
                      });
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear History'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reconnect',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Reconnect'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          Consumer<ChatService>(
            builder: (context, chatService, child) {
              if (!chatService.isConnected) {
                return Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Connecting to chat server...',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Messages list
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chatService, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatService.messages.length +
                      (chatService.messages.isNotEmpty &&
                              chatService.messages.last.isLoading
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    if (index < chatService.messages.length) {
                      final message = chatService.messages[index];
                      return MessageBubble(
                        message: message,
                        onTap: () {
                          // Copy message to clipboard
                          Clipboard.setData(
                              ClipboardData(text: message.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    } else {
                      // Show typing indicator for loading messages
                      return const TypingIndicator();
                    }
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask about weather, or anything else...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScaleTransition(
                    scale: _sendButtonAnimation,
                    child: FloatingActionButton(
                      onPressed: _sendMessage,
                      mini: true,
                      child: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
