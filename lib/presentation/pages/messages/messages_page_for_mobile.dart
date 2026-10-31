import 'package:flutter/material.dart';
import 'package:instagram/config/routes/app_routes.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/presentation/pages/messages/select_for_group_chat.dart';
import 'package:instagram/presentation/pages/messages/widgets/list_of_messages.dart';
import 'package:instagram/presentation/screens/ai_chat_screen.dart'; // 🤖 AI Chat Screen Import

class MessagesPageForMobile extends StatelessWidget {
  const MessagesPageForMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isThatMobile ? buildAppBar(context) : null,
      body: const ListOfMessages(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        // 🤖 AI Companion Shortcut Icon in AppBar
        IconButton(
          onPressed: () {
            Go(context).push(page: const AiChatScreen());
          },
          icon: const Icon(
            Icons.bolt_rounded,
            color: Colors.blueAccent, // AI Vibe Color
            size: 28,
          ),
        ),
        // Existing Group Chat / Create Icon
        IconButton(
          onPressed: () {
            Go(context).push(page: const SelectForGroupChat());
          },
          icon: Icon(
            Icons.add,
            color: Theme.of(context).focusColor,
            size: 30,
          ),
        ),
      ],
    );
  }
}
