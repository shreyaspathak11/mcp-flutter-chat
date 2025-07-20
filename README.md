# MCP Flutter Chat

A beautiful, cross-platform chat application built with Flutter that integrates with MCP (Model Context Protocol) servers. This app provides a modern mobile and web interface for chatting with AI assistants that have access to real-time tools and data.

## Features

- 🚀 **Cross-Platform**: Runs on Android, iOS, and Web
- 💬 **Real-time Chat**: WebSocket-based real-time messaging
- 🛠️ **MCP Integration**: Connects to MCP servers for tool access
- 🎨 **Modern UI**: Beautiful Material Design 3 interface
- 🌙 **Dark Mode**: Automatic dark/light theme support
- 📱 **Responsive**: Optimized for phones, tablets, and web
- ⚡ **Fast**: Efficient state management with Provider

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- For Android: Android Studio and Android SDK
- For iOS: Xcode (macOS only)
- For Web: Chrome browser

## Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Start the MCP Flask server:**
   Navigate to your `mcp-chat-app` directory and start the Flask server:
   ```bash
   cd ../mcp-chat-app
   python app.py
   ```
   The server should be running on `http://127.0.0.1:5000`

3. **Run the Flutter app:**

   For Web:
   ```bash
   flutter run -d chrome
   ```

   For Android:
   ```bash
   flutter run -d android
   ```

   For iOS (macOS only):
   ```bash
   flutter run -d ios
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── chat_message.dart     # Message data model
├── services/
│   └── chat_service.dart     # WebSocket communication service
├── screens/
│   └── chat_screen.dart      # Main chat interface
└── widgets/
    ├── message_bubble.dart   # Individual message UI
    └── typing_indicator.dart # Loading animation
```

## Configuration

The app connects to the Flask MCP server by default at:
- **Local development**: `http://127.0.0.1:5000`
- **Web version**: `http://localhost:5000`

To change the server URL, modify the `connect()` method in `lib/services/chat_service.dart`.

## Features in Detail

### Real-time Messaging
- WebSocket connection for instant message delivery
- Typing indicators when AI is processing
- Message status indicators
- Copy messages by tapping them

### MCP Tool Integration
- Automatic connection to weather MCP server
- Visual feedback when tools are being used
- Support for multiple tool types
- Error handling for failed tool calls

### Modern UI
- Material Design 3 components
- Smooth animations and transitions
- Responsive layout for all screen sizes
- Dark/light theme support
- Haptic feedback on supported devices

### Cross-Platform Support
- **Android**: Native Android app with Material Design
- **iOS**: Native iOS app with platform-specific styling
- **Web**: Progressive Web App (PWA) support

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### iOS IPA (macOS only)
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

1. **Connection issues**: Make sure the Flask server is running on port 5000
2. **Build failures**: Run `flutter clean && flutter pub get`
3. **Android v1 embedding error**: The project is configured for v2 embedding
4. **Web CORS issues**: The Flask server includes CORS headers

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple platforms
5. Submit a pull request

## License

This project is open source and available under the MIT License.
