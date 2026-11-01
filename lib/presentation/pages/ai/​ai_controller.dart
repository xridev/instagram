import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 Dotenv import kora holo
import 'package:http/http.dart' as http;
import 'ai_message_model.dart';
import 'ai_local_storage.dart';

class AiController extends ChangeNotifier {
  List<AiMessageModel> _messages = [];
  bool _isLoading = false;

  List<AiMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  // 🔑 Securely load API key from .env file
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';

  // Load initial history from local storage
  Future<void> loadChatHistory() async {
    _messages = await AiLocalStorage.loadMessages();
    
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

  // Send Message & Call Groq API
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

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama3-70b-8192", // Fast & smart open-source model
          "messages": [
            {
              "role": "system",
              "content": "You are Xrinet AI, a helpful and smart assistant created for Xriyan."
            },
            {
              "role": "user",
              "content": text
            }
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponseText = data['choices'][0]['message']['content'] ?? "Kono response ashni.";

        final aiResponse = AiMessageModel(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: aiResponseText,
          isUser: false,
          timestamp: DateTime.now(),
        );

        _messages.add(aiResponse);
      } else {
        final errorResponse = AiMessageModel(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: "Error: Server error (${response.statusCode}). Abar chesta korun.",
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errorResponse);
      }
    } catch (e) {
      final errorResponse = AiMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: "Error: Connection problem. ($e)",
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
