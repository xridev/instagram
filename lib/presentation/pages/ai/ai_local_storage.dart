import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_message_model.dart';

class AiLocalStorage {
  static const String _storageKey = 'xrinet_ai_chat_history';

  // Save Messages List Locally
  static Future<void> saveMessages(List<AiMessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = messages.map((msg) => jsonEncode(msg.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  // Load Saved Messages
  static Future<List<AiMessageModel>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_storageKey);
    
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) => AiMessageModel.fromJson(jsonDecode(jsonStr))).toList();
  }

  // Clear History
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
