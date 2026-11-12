import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/data/mock_support_service.dart';
import 'package:urban_threads/models/chat_message.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

/// Modal bottom sheet providing 24/7 Live Chat Customer Support.
///
/// Features instant connection to Marcus V. (Senior Escalation Lead),
/// priority queue indicators, quick reply prompt chips, and interactive
/// keyword resolution for urgent order disputes.
class LiveSupportSheet extends StatefulWidget {
  const LiveSupportSheet({
    this.service,
    this.orderReference,
    super.key,
  });

  final MockSupportService? service;
  final String? orderReference;

  /// Displays the Live Support bottom sheet with modal configuration.
  static Future<void> show(BuildContext context, {String? orderReference}) {
    final service = MockSupportService.shared;
    if (orderReference != null) {
      service.openOrderEscalation(orderReference);
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LiveSupportSheet(
        service: service,
        orderReference: orderReference,
      ),
    );
  }

  @override
  State<LiveSupportSheet> createState() => _LiveSupportSheetState();
}

class _LiveSupportSheetState extends State<LiveSupportSheet> {
  late final MockSupportService _service;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _prevMessageCount = 0;
  bool _prevTyping = false;

  static const List<String> _quickPrompts = [
    'Urgent: Cancel recent order',
    'Wrong delivery address',
    'Escalate payment deduction',
    'Speak with Supervisor',
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MockSupportService.shared;
    if (widget.orderReference != null) {
      _service.openOrderEscalation(widget.orderReference!);
    }
    _service.addListener(_onServiceChanged);
    _textController.addListener(_onTextChanged);
    _prevMessageCount = _service.messages.length;
    _prevTyping = _service.isTyping;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _onServiceChanged() {
    if (!mounted) return;
    setState(() {});

    final newCount = _service.messages.length;
    final newTyping = _service.isTyping;
    if (newCount != _prevMessageCount || newTyping != _prevTyping) {
      _prevMessageCount = newCount;
      _prevTyping = newTyping;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: true);
      });
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(maxScroll);
    }
  }

  void _submitMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _service.isTyping) return;
    _textController.clear();
    _service.sendMessage(text, orderReference: widget.orderReference);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: StoreColors.paper,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: StoreColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildHeader(context),
              _buildUrgencyBanner(),
              Expanded(child: _buildTranscript()),
              _buildQuickReplies(),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: StoreColors.ink),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
          const SizedBox(width: 4),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: StoreColors.ink,
                child: Text(
                  'MV',
                  style: TextStyle(
                    color: StoreColors.paper,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: StoreColors.paper, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Marcus V.',
                  style: TextStyle(
                    color: StoreColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Senior Escalation Lead · 24/7 Priority Desk',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: StoreColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _service.clearChat(),
            child: const Text(
              'Clear Chat',
              style: TextStyle(
                color: StoreColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBanner() {
    final isEscalated = _service.isEscalated;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: isEscalated
            ? StoreColors.accent.withValues(alpha: 0.1)
            : StoreColors.imageSurface.withValues(alpha: 0.5),
        border: const Border.symmetric(
          horizontal: BorderSide(color: StoreColors.line, width: 0.75),
        ),
      ),
      child: Center(
        child: Eyebrow(
          isEscalated
              ? 'PRIORITY LEVEL 1 - SUPERVISOR ESCALATED'
              : '24/7 PRIORITY ESCALATION ACTIVE',
          color: isEscalated ? StoreColors.accent : StoreColors.ink,
        ),
      ),
    );
  }

  Widget _buildTranscript() {
    final messages = _service.messages;
    final isTyping = _service.isTyping;
    final count = messages.length + (isTyping ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: _TypingIndicator(),
          );
        }

        final message = messages[index];
        if (message.isSystem) {
          return _buildSystemNotice(message);
        } else if (message.isUser) {
          return _buildUserBubble(message);
        } else {
          return _buildAgentBubble(message);
        }
      },
    );
  }

  Widget _buildSystemNotice(ChatMessage message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: StoreColors.imageSurface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StoreColors.line, width: 1),
        ),
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: StoreColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAgentBubble(ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: StoreColors.ink,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: StoreColors.paper,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildUserBubble(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: StoreColors.accent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return ActionChip(
            label: Text(prompt),
            onPressed: _service.isTyping
                ? null
                : () => _service.sendPrompt(
                      prompt,
                      orderReference: widget.orderReference,
                    ),
            backgroundColor: StoreColors.paper,
            side: const BorderSide(color: StoreColors.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _service.isTyping ? StoreColors.muted : StoreColors.ink,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    final canSend = _textController.text.trim().isNotEmpty && !_service.isTyping;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: StoreColors.line, width: 0.75),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitMessage(),
              style: const TextStyle(
                color: StoreColors.ink,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: StoreColors.muted, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: StoreColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: StoreColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: StoreColors.ink, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            key: const ValueKey('chat-send-btn'),
            icon: Icon(
              Icons.send_rounded,
              color: canSend ? StoreColors.accent : StoreColors.muted,
            ),
            onPressed: canSend ? _submitMessage : null,
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: StoreColors.ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final step = index * 0.2;
              final val = (_controller.value + step) % 1.0;
              final opacity = (0.3 + 0.7 * (1.0 - (val - 0.5).abs() * 2)).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: StoreColors.paper.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
