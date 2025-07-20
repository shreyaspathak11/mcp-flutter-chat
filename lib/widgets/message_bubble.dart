import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTap;

  const MessageBubble({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final isSystem = message.isSystem;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isSystem
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              child: Icon(
                isSystem ? Icons.info : Icons.smart_toy,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getBubbleColor(theme),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: _getTextColor(theme),
                        fontSize: 16,
                        fontStyle:
                            isSystem ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (message.isLoading) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTextColor(theme),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(
                        color: _getTextColor(theme).withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(ThemeData theme) {
    if (message.isSystem) {
      return theme.colorScheme.secondaryContainer;
    } else if (message.isUser) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.surfaceVariant;
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (message.isSystem) {
      return theme.colorScheme.onSecondaryContainer;
    } else if (message.isUser) {
      return theme.colorScheme.onPrimary;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }
}
