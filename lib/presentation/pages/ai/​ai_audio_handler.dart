import 'package:flutter/foundation.dart';

class AiAudioHandler {
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  // Start Voice Recording
  Future<void> startRecording() async {
    _isRecording = true;
    if (kDebugMode) {
      print("Voice recording started...");
    }
    // Future-e flutter_sound ba record package integration hobe
  }

  // Stop Voice Recording & Return file path
  Future<String?> stopRecording() async {
    _isRecording = false;
    if (kDebugMode) {
      print("Voice recording stopped.");
    }
    return null; // Return recorded audio file path later
  }
}
