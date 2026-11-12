import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:urban_threads/models/chat_message.dart';

/// In-memory mock service powering the 24/7 Live Chat Customer Support module.
///
/// Simulates immediate connection to Marcus V. (Senior Escalation Lead),
/// manages simulated typing latency, evaluates resolution keywords,
/// and handles priority escalation states.
class MockSupportService extends ChangeNotifier {
  MockSupportService({
    this.responseDelay = const Duration(milliseconds: 700),
    String? initialOrderReference,
  }) {
    _activeOrderReference = initialOrderReference != null
        ? formatOrderRef(initialOrderReference)
        : null;
    _seedInitialMessages(orderReference: _activeOrderReference);
  }

  static MockSupportService? _shared;

  /// Global shared instance for retaining transcript across modal dismissals.
  static MockSupportService get shared => _shared ??= MockSupportService();

  /// Sets or overrides the shared instance (useful for testing).
  static set shared(MockSupportService service) => _shared = service;

  /// Disposes and clears the shared instance.
  static void resetShared() {
    _shared?.dispose();
    _shared = null;
  }

  /// Configurable simulated response latency. Set to [Duration.zero] for tests.
  Duration responseDelay;

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isEscalated = false;
  Timer? _typingTimer;
  String? _activeOrderReference;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isEscalated => _isEscalated;
  String? get activeOrderReference => _activeOrderReference;
  bool get isTimerActive => _typingTimer?.isActive ?? false;

  /// Formats an order reference string consistently (e.g., '#UT-84920').
  static String formatOrderRef(String? orderReference) {
    if (orderReference == null || orderReference.trim().isEmpty) {
      return '#UT-84920';
    }
    final trimmed = orderReference.trim();
    if (trimmed.startsWith('Order ')) {
      return trimmed.substring(6).trim();
    }
    return trimmed;
  }

  void _seedInitialMessages({String? orderReference}) {
    final ref = formatOrderRef(orderReference);
    _messages.addAll([
      ChatMessage(
        id: 'seed-sys-welcome',
        text: 'Connected to 24/7 Priority Escalation Desk · Response time < 1 min',
        isUser: false,
        isSystem: true,
        timestamp: DateTime.now(),
        orderReference: ref,
      ),
      ChatMessage(
        id: 'seed-agent-welcome',
        text: 'Hello! I am Marcus V., Senior Escalation Lead. How can I assist you with your order or urgent streetwear inquiry today?',
        isUser: false,
        isSystem: false,
        timestamp: DateTime.now(),
        orderReference: ref,
      ),
    ]);
  }

  /// Contextual escalation opened from an order checkout flow.
  void openOrderEscalation(String orderReference) {
    final ref = formatOrderRef(orderReference);
    _activeOrderReference = ref;

    final alreadyOpened = _messages.any(
      (m) => m.isSystem && m.text.contains('Escalation opened for Order $ref'),
    );
    if (!alreadyOpened) {
      _messages.add(
        ChatMessage(
          id: 'sys-${DateTime.now().microsecondsSinceEpoch}-esc',
          text: 'Escalation opened for Order $ref',
          isUser: false,
          isSystem: true,
          timestamp: DateTime.now(),
          orderReference: ref,
        ),
      );
      _messages.add(
        ChatMessage(
          id: 'agent-${DateTime.now().microsecondsSinceEpoch}-esc',
          text: 'Hello! I see your escalation regarding Order $ref. I have placed an immediate priority hold on this order. Would you like to update your delivery address or cancel the order?',
          isUser: false,
          isSystem: false,
          timestamp: DateTime.now(),
          orderReference: ref,
        ),
      );
      notifyListeners();
    }
  }

  /// Sends a free-form user message and schedules a simulated agent response.
  void sendMessage(String text, {String? orderReference}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    cancelTimer(notify: false);

    final ref = formatOrderRef(orderReference ?? _activeOrderReference);
    _activeOrderReference = ref;

    final userMessage = ChatMessage(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
      orderReference: ref,
    );
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    if (responseDelay == Duration.zero) {
      _deliverAgentResponse(trimmed, ref);
    } else {
      _typingTimer = Timer(responseDelay, () {
        _deliverAgentResponse(trimmed, ref);
      });
    }
  }

  /// Dispatches a predefined prompt chip action.
  void sendPrompt(String text, {String? orderReference}) {
    sendMessage(text, orderReference: orderReference);
  }

  void _deliverAgentResponse(String userText, String orderRef) {
    _isTyping = false;
    _typingTimer = null;
    final responseText = _generateResponse(userText, orderRef);
    final agentMessage = ChatMessage(
      id: 'agent-${DateTime.now().microsecondsSinceEpoch}',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      orderReference: orderRef,
    );
    _messages.add(agentMessage);
    notifyListeners();
  }

  String _generateResponse(String input, String orderRef) {
    final lower = input.toLowerCase();

    if (lower.contains('supervisor') ||
        lower.contains('agent') ||
        lower.contains('human')) {
      _isEscalated = true;
      return 'I have escalated this case to PRIORITY LEVEL 1 - SUPERVISOR ESCALATED. A senior operations supervisor has joined this session to resolve your inquiry immediately.';
    }

    if (lower.contains('cancel')) {
      return 'I have initiated an urgent cancellation hold for Order $orderRef. The warehouse fulfillment has been halted, and a full refund will be credited back to your original payment method.';
    }

    if (lower.contains('address')) {
      return 'I have placed a 15-minute shipping hold on Order $orderRef. Please enter your updated street address below.';
    }

    if (lower.contains('refund') || lower.contains('payment')) {
      return 'I have initiated a priority billing investigation hold for Order $orderRef. Our accounts team will review and ensure all unauthorized or disputed charges are refunded immediately.';
    }

    if (lower.contains('delay') || lower.contains('tracking')) {
      return 'I have verified that Order $orderRef is currently being prioritized at our express logistics hub. Carrier tracking updates will reflect expedited dispatch.';
    }

    return 'Thank you for contacting Urban Threads 24/7 Priority Support. I am reviewing your request regarding Order $orderRef and will ensure an immediate resolution.';
  }

  /// Resets the session back to the clean initial state with welcome messages.
  void resetSession({String? orderReference}) {
    cancelTimer(notify: false);
    _isTyping = false;
    _isEscalated = false;
    _messages.clear();
    _activeOrderReference = orderReference != null ? formatOrderRef(orderReference) : null;
    _seedInitialMessages(orderReference: _activeOrderReference);
    notifyListeners();
  }

  /// Wipes all transcript messages.
  void clearChat() {
    cancelTimer(notify: false);
    _isTyping = false;
    _isEscalated = false;
    _messages.clear();
    notifyListeners();
  }

  /// Cancels any scheduled agent response timer.
  void cancelTimer({bool notify = true}) {
    if (_typingTimer != null) {
      _typingTimer?.cancel();
      _typingTimer = null;
    }
    if (_isTyping) {
      _isTyping = false;
      if (notify) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    cancelTimer(notify: false);
    super.dispose();
  }
}
