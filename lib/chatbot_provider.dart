import 'package:flutter/material.dart';
import 'data/services/chatbot_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotProvider extends ChangeNotifier {
  final ChatbotService _chatbotService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatbotProvider({required ChatbotService chatbotService})
      : _chatbotService = chatbotService;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  /// Send a message to the chatbot and get a response
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(text: message, isUser: true));
    notifyListeners();

    // Set loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Get response from chatbot
      final response = await _chatbotService.sendMessage(message);

      // Add chatbot response
      _messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      // Add error message
      _messages.add(ChatMessage(
        text: 'Sorry, I encountered an error: ${e.toString()}',
        isUser: false,
      ));
    } finally {
      // Clear loading state
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the chat history
  void clearChat() {
    _messages.clear();
    _chatbotService.clearHistory();
    notifyListeners();
  }
}