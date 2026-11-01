import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_message_model.dart';
import 'ai_local_storage.dart';

class AiController extends ChangeNotifier {
  List<AiMessageModel> _messages = [];
  bool _isLoading = false;

  List<AiMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  // 🔑 Apnar Gemini API Key ekhane bosiye deben (Google AI Studio theke free te paoa jay)
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

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

  // Send Message & Call Real Gemini API
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

    // Call Real AI API
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize Generative Model (Gemini 1.5 Flash is fast & efficient)
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final content = [Content.text(text)];
      final response = await model.generateContent(content);

      final aiResponseText = response.text ?? "Kono response ashni, abar chesta korun.";

      final aiResponse = AiMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiResponse);
    } catch (e) {
      // Error handling agar API key ba internet-e problem thake
      final errorResponse = AiMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: "Error: AI response pete somossa hocche. ($e)",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorResponse);
    } finally {
      _isLoading = false;
      notifyListeners();
      await AiLocalStorage.saveMessages(_messages);
    }
  }

  // Clear History
  Future<void> clearChat() async {
    await AiLocalStorage.clearHistory();
    _messages.clear();
    loadChatHistory();
  }
}
