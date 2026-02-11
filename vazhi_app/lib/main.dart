/// VAZHI - Tamil AI Assistant
///
/// Main entry point for the application.
library;


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'screens/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VazhiApp()));
}

class VazhiApp extends StatelessWidget {
  const VazhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAZHI வழி',
      debugShowCheckedModeBanner: false,
      theme: VazhiTheme.buildTheme(),
      home: const ChatScreen(),
    );
  }
}
