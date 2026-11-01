import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:instagram/presentation/pages/ai/ai_message_model.dart';
import 'package:instagram/presentation/pages/ai/ai_local_storage.dart';

// --- AI CONTROLLER CLASS ---
class AiController extends ChangeNotifier {
  List<AiMessageModel> _messages = [];
  bool _isLoading = false;

  List<AiMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';

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
          "model": "llama3-70b-8192",
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

  Future<void> clearChat() async {
    await AiLocalStorage.clearHistory();
    _messages.clear();
    loadChatHistory();
  }
}

// --- AI CHAT SCREEN UI ---
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiController _aiController = AiController();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _aiController.addListener(_onAiControllerChanged);
    _aiController.loadChatHistory();
  }

  @override
  void dispose() {
    _aiController.removeListener(_onAiControllerChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onAiControllerChanged() {
    setState(() {});
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    _aiController.sendMessage(_textController.text);
    _textController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.5,
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF262626),
                  child: Icon(Icons.bolt, color: Colors.blueAccent, size: 20),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Xrinet AI",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Active now",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.grey),
            onPressed: () => _aiController.clearChat(),
            tooltip: "Clear Chat History",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _aiController.messages.length,
              itemBuilder: (context, index) {
                final message = _aiController.messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          if (_aiController.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Xrinet AI is typing...",
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic_rounded, color: Colors.white70),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Message Xrinet AI...",
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final AiMessageModel message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF00378B) : const Color(0xFF262626),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
