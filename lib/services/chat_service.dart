import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/chat_message.dart';

class ChatService extends ChangeNotifier {
  late io.Socket _socket;
  String? _sessionId;
  bool _isConnected = false;
  bool _isConnectedToServer = false;
  List<ChatMessage> _messages = [];
  String _connectionStatus = 'Disconnected';
  List<Map<String, dynamic>> _availableTools = [];

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnectedToServer => _isConnectedToServer;
  List<ChatMessage> get messages => _messages;
  String get connectionStatus => _connectionStatus;
  List<Map<String, dynamic>> get availableTools => _availableTools;
  String? get sessionId => _sessionId;

  // Connect to Flask-SocketIO server
  void connect({String host = '192.168.0.159', int port = 5000}) {
    try {
      final url = kIsWeb ? 'http://localhost:$port' : 'http://$host:$port';

      _socket = io.io(url, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket.onConnect((_) {
        _isConnected = true;
        _connectionStatus = 'Connected to chat server';
        _addSystemMessage('🌐 Connected to chat server');
        notifyListeners();
      });

      _socket.onDisconnect((_) {
        _isConnected = false;
        _isConnectedToServer = false;
        _connectionStatus = 'Disconnected';
        _addSystemMessage('❌ Disconnected from server');
        notifyListeners();
      });

      _socket.on('session_created', (data) {
        _sessionId = data['session_id'];
        _addSystemMessage(
            '🎯 Session created: ${_sessionId?.substring(0, 8)}...');
        // Auto-connect to weather server
        connectToMCPServer('weather');
        notifyListeners();
      });

      _socket.on('server_connected', (data) {
        if (data['success']) {
          _isConnectedToServer = true;
          _connectionStatus = 'Connected to ${data['server']}';
          _availableTools = List<Map<String, dynamic>>.from(data['tools']);
          _addSystemMessage(
              '🎉 Connected to ${data['server']}! You can now ask questions and I\'ll use available tools to help you.');
        } else {
          _addSystemMessage(
              '❌ Failed to connect to MCP server: ${data['error']}');
        }
        notifyListeners();
      });

      _socket.on('message_update', (data) {
        if (data['type'] == 'text') {
          _updateLastAssistantMessage(data['content']);
        } else if (data['type'] == 'tool_call') {
          _addSystemMessage('🔧 Using ${data['tool']} tool...');
        }
        notifyListeners();
      });

      _socket.on('message_complete', (data) {
        if (data['error'] != null) {
          _addSystemMessage('❌ Error: ${data['error']}');
        } else {
          // Message was already updated via message_update events
          _finalizeLastAssistantMessage();
        }
        notifyListeners();
      });

      _socket.on('history_cleared', (data) {
        if (data['success']) {
          _messages.clear();
          _addSystemMessage('🧹 Chat history cleared');
        }
        notifyListeners();
      });

      _socket.connect();
    } catch (e) {
      _connectionStatus = 'Connection failed: $e';
      _addSystemMessage('❌ Connection failed: $e');
      notifyListeners();
    }
  }

  void connectToMCPServer(String serverType) {
    if (_sessionId != null) {
      _socket.emit('connect_server', {
        'session_id': _sessionId,
        'server_type': serverType,
      });
    }
  }

  void sendMessage(String content) {
    if (!_isConnectedToServer || _sessionId == null) {
      _addSystemMessage('❌ Please connect to a server first');
      return;
    }

    // Add user message
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    // Add placeholder assistant message
    _addMessage(ChatMessage(
      id: 'assistant_${DateTime.now().millisecondsSinceEpoch}',
      content: '...',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    ));

    // Send to server
    _socket.emit('send_message', {
      'session_id': _sessionId,
      'message': content,
    });

    notifyListeners();
  }

  void clearHistory() {
    if (_sessionId != null) {
      _socket.emit('clear_history', {'session_id': _sessionId});
    }
  }

  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
  }

  void _addSystemMessage(String content) {
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      isSystem: true,
    ));
  }

  void _updateLastAssistantMessage(String content) {
    if (_messages.isNotEmpty && !_messages.last.isUser) {
      final lastMessage = _messages.last;
      if (lastMessage.isLoading || lastMessage.content == '...') {
        _messages[_messages.length - 1] = lastMessage.copyWith(
          content: content,
          isLoading: false,
        );
      } else {
        _messages[_messages.length - 1] = lastMessage.copyWith(
          content: lastMessage.content + content,
        );
      }
    }
  }

  void _finalizeLastAssistantMessage() {
    if (_messages.isNotEmpty && !_messages.last.isUser) {
      final lastMessage = _messages.last;
      _messages[_messages.length - 1] = lastMessage.copyWith(
        isLoading: false,
      );
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
