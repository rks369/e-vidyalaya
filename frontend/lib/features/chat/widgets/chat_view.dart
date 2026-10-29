import 'dart:async';

import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/models/message_model.dart';
import 'package:evidyalaya/core/services/chat_socket.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/features/auth/bloc/auth_cubit.dart';
import 'package:evidyalaya/features/chat/services/chat_service.dart';
import 'package:evidyalaya/features/chat/widgets/group_message_bubble.dart';
import 'package:evidyalaya/features/chat/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatView extends StatefulWidget {

  const ChatView({
    super.key,
    required this.kind,
    required this.targetId,
  });

  final ChatKind kind;
  final int targetId;

  @override
  State<ChatView> createState() => _ChatViewState();

}

class _ChatViewState extends State<ChatView> {

  static const _pollInterval = Duration(seconds: 10);

  final _controller = TextEditingController();
  final _messages = <MessageModel>[];
  Timer? _timer;
  StreamSubscription<LiveMessage>? _live;
  bool _loaded = false;
  bool _polling = false;
  bool _sending = false;
  String? _error;

  bool get _isGroup => widget.kind != ChatKind.user;

  @override
  void initState() {

    super.initState();
    _poll();
    _join();
    _timer = Timer.periodic(
      _pollInterval,
      (_) => _poll(),
    );

  }

  Future<void> _join() async {

    try {
      final key = await ChatSocket.instance.join(
        kind: widget.kind,
        id: widget.targetId,
      );
      if (!mounted) {
        ChatSocket.instance
            .leave(
              kind: widget.kind,
              id: widget.targetId,
            )
            .catchError((_) {});
        return;
      }
      _live = ChatSocket.instance.messages
          .where((event) => event.key == key)
          .listen((event) => _add(message: event.message));
    } on ApiException {
      return;
    }

  }

  void _add({required MessageModel message}) {

    if (!mounted || _messages.any((m) => m.id == message.id)) {
      return;
    }
    setState(() => _messages.add(message));

  }

  @override
  void dispose() {

    _timer?.cancel();
    _live?.cancel();
    ChatSocket.instance.leave(
      kind: widget.kind,
      id: widget.targetId,
    ).catchError((_) {});
    _controller.dispose();
    super.dispose();

  }

  Future<void> _poll() async {

    if (_polling) {
      return;
    }
    _polling = true;
    try {
      final fresh = await ChatService.fetch(
        kind: widget.kind,
        id: widget.targetId,
        afterId: _messages.isEmpty ? null : _messages.last.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {

        _messages.addAll(
          fresh.where((m) => !_messages.any((o) => o.id == m.id)),
        );
        _loaded = true;
        _error = null;

      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {

          _loaded = true;
          _error = e.message;

        });
      }
    } finally {
      _polling = false;
    }

  }

  Future<void> _send() async {

    final text = _controller.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    try {
      final sent = await ChatSocket.instance.send(
        kind: widget.kind,
        id: widget.targetId,
        body: text,
      );
      if (!mounted) {
        return;
      }
      _controller.clear();
      _add(message: sent);
    } on ApiException catch (e) {
      if (mounted) {
        showErrorMessage(
          context: context,
          error: e.message,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    final myId = context.read<AuthCubit>().userId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildMessages(myId: myId)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Send',
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }

  Widget _buildMessages({required int myId}) {

    if (!_loaded) {
      return const Loading();
    }
    if (_messages.isEmpty) {
      return Center(child: Text(_error ?? 'No message Exixts !!!'));
    }
    final newestFirst = _messages.reversed.toList();
    return ListView.builder(
      reverse: true,
      itemCount: newestFirst.length,
      itemBuilder: (context, index) {

        final message = newestFirst[index];
        final isMe = message.senderId == myId;
        return _isGroup
            ? GroupMessageBubble(
                senderName: message.senderName,
                text: message.body,
                isMe: isMe,
              )
            : MessageBubble(
                text: message.body,
                isMe: isMe,
            );

      },
    );

  }

}
