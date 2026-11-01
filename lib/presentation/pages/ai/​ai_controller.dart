import 'package:flutter/foundation.dart';
import '../models/ai_message_model.dart';
import '../data/ai_local_storage.dart';

class AiController extends ChangeNotifier {
  List<AiMessageModel> _messages = [];
  bool _isLoading = false;

  List<AiMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  // Load initial history from local storage
  Future<void> loadChatHistory() async {
    _messages = await AiLocalStorage.loadMessages();
    
    // Jodi kono history na thake, tahole default welcome message add hobe
    if (_messages.isEmpty) {
      _messages.add(
        AiMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Hello Xriyan! Ami apnar Xrinet AI companion. Ajke ki niye kotha bolbo?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      await AiLocalStorage.saveMessages(_messages);
    }
    notifyListeners();
  }

  // Send Message & Save to Local Storage
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = AiMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    notifyListeners();
    await AiLocalStorage.saveMessages(_messages);

    // Simulate AI thinking / Response generation (Future-e ekhane API connect hobe)
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final aiResponse = AiMessageModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: "Bujhte perechi! '$text' er byapare porobortite real-time API connect kora hobe.",
      isUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(aiResponse);
    _isLoading = false;
    notifyListeners();
    await AiLocalStorage.saveMessages(_messages);
  }

  // Clear History
  Future<void> clearChat() async {
    await AiLocalStorage.clearHistory();
    _messages.clear();
    loadChatHistory();
  }
}
