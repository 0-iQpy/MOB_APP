# 24/7 Live Chat Customer Support for Urgent / Escalated Problems

*   **Author:** Antigravity / Engineering Team
*   **Status:** Approved (Post-EGM Goldfish Review)
*   **Date:** 2026-11-12

--------------------------------------------------------------------------------

## Overview

This technical specification defines the design and implementation for an offline-capable, interactive **24/7 Live Chat Customer Support** module for the URBAN THREADS mobile storefront Flutter demonstration. The feature provides students and evaluators with a realistic demonstration of priority customer service escalation, order-linked problem resolution, and responsive conversational UI without requiring external server dependencies or live network infrastructure.

--------------------------------------------------------------------------------

## The Problem

E-commerce streetwear applications require immediate, high-priority conflict resolution mechanisms when orders encounter critical issues—such as incorrect shipping destinations, urgent cancellation requests before warehouse fulfillment, or simulated payment disputes. Currently, URBAN THREADS features a simulated checkout sheet, but lacks an in-app customer service destination. Evaluators testing the app cannot simulate post-purchase problem resolution or observe customer care workflows.

--------------------------------------------------------------------------------

## Goals

1. **Contextual & Global Access Points**:
   - Provide a global Support action icon (`Icons.headset_mic_outlined`) in `StoreHeader` (accessible across Discover and Catalog).
   - Provide a direct contextual escalation Call to Action (CTA) on the Order Confirmed checkout screen (`"Need urgent help with Order #UT-84920? Chat with Support"`).
2. **Realistic 24/7 Priority Simulation**:
   - Render a designated priority escalation banner (`"Status: Connected to Priority Desk · Response time < 1 min"`).
   - Display active agent identity and status (`Marcus V. · Senior Escalation Lead` with active green status beacon).
   - Present situational prompt chips for common demo triggers:
     - `"Urgent: Cancel recent order"`
     - `"Wrong delivery address"`
     - `"Escalate payment deduction"`
     - `"Speak with Supervisor"`
3. **Interactive Conversational Engine**:
   - Support interactive message entry via text field and prompt chips.
   - Provide an animated typing indicator with configurable simulated latency (defaulting to 700ms in UI, `Duration.zero` in unit tests) before dispatching context-aware mock responses.
   - Handle keyword matching for standard support scenarios (`cancel`, `address`, `refund`, `supervisor`, `delay`, `agent`).
4. **Offline Resilience & Zero-Dependency Execution**:
   - Operate 100% offline with zero external network dependencies or third-party SDKs.
   - Maintain 0 errors on `flutter analyze` and 100% test coverage across existing and new flows.

--------------------------------------------------------------------------------

## Non-Goals

1. Real-time WebSocket or HTTP backend server infrastructure.
2. Cross-device cloud conversation synchronization or persistent backend databases.
3. Voice calling, WebRTC video calling, or live file attachment uploads.
4. Heavy third-party chat SDK integrations (e.g., Zendesk, Intercom) requiring API keys and live connectivity.

--------------------------------------------------------------------------------

## Open Questions & Decisions

*   **Question 1**: Should the chat sheet persist conversation history during app navigation?
    *   *Decision*: Yes. Manage transcript state in a lightweight `MockSupportService` `ChangeNotifier` so evaluators can close the sheet, browse styles, and reopen support with existing messages preserved.
*   **Question 2**: How should the live chat UI integrate with the existing `StoreColors` design system?
    *   *Decision*: Adhere strictly to existing codebase constants: `StoreColors.ink` (`0xFF171715`), `StoreColors.paper` (`0xFFF4F1EB`), `StoreColors.accent` (`0xFFE4482E`), `StoreColors.line` (`0xFFD8D3CB`), and reuse the existing `Eyebrow` primitive from `lib/widgets/store_primitives.dart`.

--------------------------------------------------------------------------------

## Critical User Journeys (CUJs)

### CUJ 1: Contextual Escalation from Checkout Confirmation

*   **Given**: The user has completed a simulated purchase and is viewing the `ORDER CONFIRMED` bottom sheet with generated reference `Order #UT-84920`.
*   **When**: The user taps the button `"Need urgent help with this order? Chat with Support"`.
*   **Then**: The checkout sheet is dismissed (`Navigator.of(context).pop()`), and `LiveSupportSheet` opens immediately, pre-populating a system notification message: `"Escalation opened for Order #UT-84920"`. The agent greets the user by order reference and offers one-tap cancellation or address correction.

### CUJ 2: Global Header Live Chat Launch & Prompt Chip Interaction

*   **Given**: The user is browsing the Discover screen or Catalog screen.
*   **When**: The user taps the Support headset icon in `StoreHeader`.
*   **Then**: The Live Chat modal opens with live status indicators. The user taps `"Wrong delivery address"`.
*   **Then**: The message is added to the transcript, an animated typing indicator displays for 700ms, and the agent responds: `"I have placed a 15-minute shipping hold on Order #UT-84920. Please enter your updated street address below."`

### CUJ 3: Free-form Text Entry with Keyword-Driven Resolution

*   **Given**: The user has an open chat session.
*   **When**: The user types `"I want to speak with a human supervisor immediately"` and submits.
*   **Then**: The system flags the ticket as `"PRIORITY LEVEL 1 - SUPERVISOR ESCALATED"`, changes the header status badge to high-urgency accent color, and responds with immediate supervisory acknowledgment.

--------------------------------------------------------------------------------

## Technical Plan (Architecture)

### Component Architecture

```text
+-------------------------------------------------------------------------+
|                              URBAN THREADS                              |
|                                                                         |
|   [Top App Bar: StoreHeader]                                            |
|   URBAN.THREADS                        [Support Icon] [Cart Bag]        |
|                                              |                          |
|   [SimulatedCheckoutSheet (Success State)]   |                          |
|   "Need urgent help with Order #UT-84920?" --+                          |
|                                              |                          |
|                                              v                          |
|   +-----------------------------------------------------------------+   |
|   |                   LiveSupportSheet (Modal Bottom Sheet)         |   |
|   |  - Header: Agent Marcus V. (Senior Escalation) + Green Beacon   |   |
|   |  - Urgency Ribbon: Eyebrow("24/7 PRIORITY ESCALATION ACTIVE")   |   |
|   |  - Message List (ListView.builder with ScrollController)        |   |
|   |      * System Notice: Order Reference / Shipping Hold Notice    |   |
|   |      * Agent Bubble (StoreColors.ink / Paper Text)              |   |
|   |      * User Bubble (StoreColors.accent / White Text)            |   |
|   |      * Animated Typing Indicator (Dot Pulse)                    |   |
|   |  - Quick Reply Chips (Horizontally Scrollable)                  |   |
|   |  - Text Input Bar (TextField + Send IconButton)                 |   |
|   +-----------------------------------------------------------------+   |
|                                  ^                                      |
|                                  | listens / dispatches                 |
|   +-----------------------------------------------------------------+   |
|   |                   MockSupportService (ChangeNotifier)           |   |
|   |  - List<ChatMessage> _messages                                  |   |
|   |  - bool _isTyping                                               |   |
|   |  - bool _isEscalated                                            |   |
|   |  - Timer? _typingTimer (managed cancellation on dispose)        |   |
|   |  - Duration responseDelay (configurable, Duration.zero in test) |   |
|   |  - sendMessage(), sendPrompt(), resetSession()                  |   |
|   +-----------------------------------------------------------------+   |
+-------------------------------------------------------------------------+
```

### Data Models & Service Logic

1. **`ChatMessage` (`lib/models/chat_message.dart`)**:
   ```dart
   class ChatMessage {
     const ChatMessage({
       required this.id,
       required this.text,
       required this.isUser,
       required this.timestamp,
       this.isSystem = false,
       this.orderReference,
     });
     final String id;
     final String text;
     final bool isUser;
     final DateTime timestamp;
     final bool isSystem;
     final String? orderReference;
   }
   ```

2. **`MockSupportService` (`lib/data/mock_support_service.dart`)**:
   - Extends `ChangeNotifier`.
   - Manages stateful message stream, typing status, and escalation flag.
   - Evaluates keywords (`cancel`, `address`, `refund`, `supervisor`, `delay`, `agent`, `tracking`) to return authoritative streetwear customer care responses.
   - Uses managed `Timer? _typingTimer` with explicit cancellation on `dispose()`.
   - Supports `responseDelay` parameter (`const Duration(milliseconds: 700)` default, `Duration.zero` for automated tests).

--------------------------------------------------------------------------------

## Alternatives Considered

### Alternative A: Modal Bottom Sheet vs. Dedicated Full-Screen PageRoute

*   **Pros of Modal Bottom Sheet**: Preserves storefront browsing context, feels lightweight and accessible, aligns with existing `SimulatedCheckoutSheet` pattern.
*   **Cons**: Requires handling `viewInsets.bottom` for soft keyboard occlusion and auto-scrolling.
*   **Chosen Approach**: Modal Bottom Sheet with `isScrollControlled: true`, `useSafeArea: true`, and padding offset by `MediaQuery.of(context).viewInsets.bottom`.

### Alternative B: Rule-Based Scenario Engine vs. Local NLP/LLM Embedding Engine

*   **Pros of Rule-Based Engine**: 100% deterministic, instant execution, zero runtime dependencies, completely offline-compatible.
*   **Cons of Local NLP/LLM**: Bloats app bundle size by hundreds of megabytes and introduces non-deterministic response latency.
*   **Chosen Approach**: Deterministic rule-based keyword and prompt-chip engine with an authoritative fallback response.

--------------------------------------------------------------------------------

## Risks, Failure Modes & Mitigations

1. **Sheet Dismissal with Active Response Timer**:
   - *Risk*: Evaluator closes the sheet while a simulated agent response is scheduled.
   - *Mitigation*: `MockSupportService` manages the `Timer?` independently of the transient widget lifecycle. When the sheet is dismissed and reopened, messages are preserved. `MockSupportService.dispose()` cleanly cancels pending timers.
2. **Keyboard Viewport Inset Occlusion**:
   - *Risk*: The soft keyboard pops up and covers the message input field.
   - *Mitigation*: The sheet sets `isScrollControlled: true` and wraps the bottom container in `Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))`.
3. **Modal Stacking & Scrim Accumulation**:
   - *Risk*: Opening `LiveSupportSheet` on top of an already open `SimulatedCheckoutSheet` locks navigation gestures.
   - *Mitigation*: The escalation button in `SimulatedCheckoutSheet` invokes `Navigator.of(context).pop()` before calling `LiveSupportSheet.show(context, orderReference: ...)`.
4. **Rapid Quick-Reply Spam**:
   - *Risk*: Evaluator taps a quick-reply chip multiple times in rapid succession, creating duplicate messages and overlapping timers.
   - *Mitigation*: Quick-reply chips and the send button are disabled while `isTyping == true`.

--------------------------------------------------------------------------------

## Detailed Implementation Plan

### Target Files & Phased Execution

#### Phase 1: Foundation Data Model
*   **`lib/models/chat_message.dart` (Create)**
    - Implement immutable `ChatMessage` class with fields: `id`, `text`, `isUser`, `timestamp`, `isSystem`, `orderReference`.

#### Phase 2: Logic & Simulation Service
*   **`lib/data/mock_support_service.dart` (Create)**
    - Implement `MockSupportService` extending `ChangeNotifier`.
    - Provide pre-seeded introductory messages (`"Marcus V. connected to Priority Escalation Desk"`).
    - Provide keyword matching for `cancel`, `address`, `refund`, `supervisor`, `delay`, `agent`, and a robust fallback response.
    - Provide `sendMessage(String text, {String? orderReference})`, `sendPrompt(String text, {String? orderReference})`, and `resetSession()`.
    - Ensure `Timer? _typingTimer` is safely managed and cancellable.

#### Phase 3: Presentation UI Component
*   **`lib/widgets/live_support_sheet.dart` (Create)**
    - Implement `LiveSupportSheet` with static `show(BuildContext context, {String? orderReference})`.
    - Build header with agent avatar, name, green beacon, and "Clear Chat" reset action.
    - Render priority queue banner using `Eyebrow`.
    - Build message list using `ListView.builder` connected to `ScrollController` with auto-scrolling to bottom on new messages.
    - Render horizontal quick-reply chips (disabled when typing).
    - Build text input field with send button (disabled when input is empty or agent is typing).

#### Phase 4: App Integration
*   **`lib/widgets/store_header.dart` (Modify)**
    - Add an `IconButton` (`Icons.headset_mic_outlined`, tooltip: `'Live Support'`, key: `ValueKey('open-live-support')`) immediately preceding the cart Bag button.
*   **`lib/widgets/simulated_checkout_sheet.dart` (Modify)**
    - In the `'ORDER CONFIRMED'` view step, add a secondary action button:
      `OutlinedButton.icon(icon: Icon(Icons.support_agent), label: Text('Need urgent help? Chat with Priority Support'))`.
    - On tap, call `Navigator.of(context).pop()` then `LiveSupportSheet.show(context, orderReference: '#UT-84920')`.

#### Phase 5: Automated Testing & Verification
*   **`test/widget_test.dart` (Modify)**
    - Add test: `'launches live support from header and sends quick reply chip'`
    - Add test: `'launches live support contextually from checkout confirmation with order hold notice'`
    - Add test: `'submits supervisor escalation and updates priority status'`
    - Ensure `flutter analyze` reports 0 warnings and `flutter test` passes 100%.

### Verification Plan

*   **Static Analysis**: `flutter analyze` passing with 0 warnings or errors.
*   **Automated Tests**: `flutter test` executing all existing and new widget tests with 100% pass rate.
*   **Manual Verification**: Launch app, simulate order checkout, trigger live chat escalation, submit custom messages, and verify typing indicator and mock response timing.

--------------------------------------------------------------------------------

*Drafted with EGM*
