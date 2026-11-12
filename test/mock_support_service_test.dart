import 'package:flutter_test/flutter_test.dart';
import 'package:urban_threads/data/mock_support_service.dart';
import 'package:urban_threads/models/chat_message.dart';

void main() {
  group('ChatMessage', () {
    test('creates ChatMessage with expected fields', () {
      final now = DateTime.now();
      final msg = ChatMessage(
        id: 'msg-1',
        text: 'Hello world',
        isUser: true,
        timestamp: now,
        isSystem: false,
        orderReference: '#UT-12345',
      );

      expect(msg.id, 'msg-1');
      expect(msg.text, 'Hello world');
      expect(msg.isUser, isTrue);
      expect(msg.timestamp, now);
      expect(msg.isSystem, isFalse);
      expect(msg.orderReference, '#UT-12345');
    });
  });

  group('MockSupportService', () {
    late MockSupportService service;

    setUp(() {
      service = MockSupportService(responseDelay: Duration.zero);
    });

    tearDown(() {
      service.dispose();
    });

    test('pre-seeds welcome messages from Marcus V. and priority desk', () {
      expect(service.messages.length, 2);
      expect(service.messages[0].isSystem, isTrue);
      expect(service.messages[0].text, contains('24/7 Priority Escalation Desk'));
      expect(service.messages[1].isUser, isFalse);
      expect(service.messages[1].text, contains('Marcus V.'));
      expect(service.isTyping, isFalse);
      expect(service.isEscalated, isFalse);
    });

    test('responds to address keyword with 15-minute shipping hold', () {
      service.sendMessage('Wrong delivery address', orderReference: '#UT-84920');

      expect(service.messages.length, 4);
      final userMsg = service.messages[2];
      final agentMsg = service.messages[3];

      expect(userMsg.isUser, isTrue);
      expect(userMsg.text, 'Wrong delivery address');
      expect(agentMsg.isUser, isFalse);
      expect(agentMsg.text, contains('15-minute shipping hold on Order #UT-84920'));
      expect(agentMsg.text, contains('Please enter your updated street address below.'));
    });

    test('responds to cancel keyword with cancellation hold and refund confirmation', () {
      service.sendMessage('I need to cancel my order', orderReference: '#UT-84920');

      final agentMsg = service.messages.last;
      expect(agentMsg.text, contains('cancellation hold for Order #UT-84920'));
      expect(agentMsg.text, contains('full refund will be credited back'));
    });

    test('responds to refund and payment keywords with billing investigation hold', () {
      service.sendMessage('Escalate payment deduction', orderReference: '#UT-84920');

      final agentMsg = service.messages.last;
      expect(agentMsg.text, contains('priority billing investigation hold'));
    });

    test('responds to supervisor keyword, flags isEscalated, and escalates ticket', () {
      expect(service.isEscalated, isFalse);

      service.sendMessage('Speak with Supervisor');

      expect(service.isEscalated, isTrue);
      final agentMsg = service.messages.last;
      expect(agentMsg.text, contains('PRIORITY LEVEL 1 - SUPERVISOR ESCALATED'));
    });

    test('responds to agent and human keywords with escalation', () {
      service.sendMessage('I want to talk to a human agent');

      expect(service.isEscalated, isTrue);
      expect(service.messages.last.text, contains('PRIORITY LEVEL 1 - SUPERVISOR ESCALATED'));
    });

    test('responds to delay and tracking keywords', () {
      service.sendMessage('Where is my tracking number, is there a delay?');

      final agentMsg = service.messages.last;
      expect(agentMsg.text, contains('express logistics hub'));
    });

    test('provides fallback resolution response for general inquiries', () {
      service.sendMessage('Do you sell vintage oversized bombers?');

      final agentMsg = service.messages.last;
      expect(agentMsg.text, contains('Urban Threads 24/7 Priority Support'));
      expect(agentMsg.text, contains('immediate resolution'));
    });

    test('openOrderEscalation adds contextual escalation messages', () {
      service.openOrderEscalation('#UT-84920');

      expect(service.messages.any((m) => m.text.contains('Escalation opened for Order #UT-84920')), isTrue);
      expect(service.messages.any((m) => m.text.contains('priority hold on this order')), isTrue);

      // Verify idempotency (duplicate call does not duplicate escalation notice)
      final count = service.messages.length;
      service.openOrderEscalation('#UT-84920');
      expect(service.messages.length, count);
    });

    test('clearChat removes all messages and resets typing/escalation', () {
      service.sendMessage('Speak with Supervisor');
      expect(service.isEscalated, isTrue);
      expect(service.messages.isNotEmpty, isTrue);

      service.clearChat();

      expect(service.messages.isEmpty, isTrue);
      expect(service.isEscalated, isFalse);
      expect(service.isTyping, isFalse);
    });

    test('resetSession restores welcome messages and resets state', () {
      service.sendMessage('Speak with Supervisor');
      expect(service.isEscalated, isTrue);

      service.resetSession();

      expect(service.messages.length, 2);
      expect(service.isEscalated, isFalse);
      expect(service.isTyping, isFalse);
      expect(service.messages[1].text, contains('Marcus V.'));
    });

    test('sendPrompt forwards to sendMessage', () {
      service.sendPrompt('Wrong delivery address');
      expect(service.messages.any((m) => m.text == 'Wrong delivery address'), isTrue);
    });
  });

  group('MockSupportService with Timer Latency', () {
    testWidgets('manages typing state and completes via timer', (tester) async {
      final service = MockSupportService(responseDelay: const Duration(milliseconds: 300));
      expect(service.isTyping, isFalse);

      service.sendMessage('Wrong delivery address');
      expect(service.isTyping, isTrue);
      expect(service.isTimerActive, isTrue);

      await tester.pump(const Duration(milliseconds: 150));
      expect(service.isTyping, isTrue);

      await tester.pump(const Duration(milliseconds: 200));
      expect(service.isTyping, isFalse);
      expect(service.isTimerActive, isFalse);
      expect(service.messages.last.text, contains('15-minute shipping hold'));

      service.dispose();
    });

    testWidgets('cancelTimer aborts scheduled agent response', (tester) async {
      final service = MockSupportService(responseDelay: const Duration(milliseconds: 300));
      service.sendMessage('Cancel my order');
      expect(service.isTyping, isTrue);

      service.cancelTimer();
      expect(service.isTyping, isFalse);
      expect(service.isTimerActive, isFalse);

      await tester.pump(const Duration(milliseconds: 400));
      // Agent message was never delivered because timer was cancelled
      expect(service.messages.last.isUser, isTrue);

      service.dispose();
    });
  });
}
