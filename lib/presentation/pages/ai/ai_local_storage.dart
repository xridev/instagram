class AiMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Convert to Map for Local Storage (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Map (JSON)
  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
