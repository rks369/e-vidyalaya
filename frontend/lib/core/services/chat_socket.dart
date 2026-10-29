import 'dart:async';

import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/config/env.dart';
import 'package:evidyalaya/core/models/message_model.dart';
import 'package:evidyalaya/features/chat/services/chat_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class LiveMessage {

  const LiveMessage({
    required this.key,
    required this.message,
  });

  final String key;
  final MessageModel message;

}

class ChatSocket {

  ChatSocket._();

  static final instance = ChatSocket._();

  static const _ackTimeout = Duration(seconds: 20);

  final _live = StreamController<LiveMessage>.broadcast();
  final _joined = <(
    ChatKind,
    int,
  )>{};

  io.Socket? _socket;
  String? _token;

  Stream<LiveMessage> get messages => _live.stream;

  Future<String> join({
    required ChatKind kind,
    required int id,
  }) async {

    final data = await _request(
      event: 'chat:join', payload: {
      'kind': _kind(kind: kind),
      'id': id,
    });
    _joined.add(
      (
        kind,
        id,
      ),
    );

    return data['key'] as String;

  }

  Future<void> leave({
    required ChatKind kind,
    required int id,
  }) async {

    _joined.remove(
      (
        kind,
        id,
      ),
    );
    if (_socket?.connected ?? false) {
      await _request(
        event: 'chat:leave', payload: {
        'kind': _kind(kind: kind),
        'id': id,
      });
    }

  }

  Future<MessageModel> send({
    required ChatKind kind,
    required int id,
    required String body,
  }) async {

    final data = await _request(
      event: 'chat:send',
      payload: {
        'kind': _kind(kind: kind),
        'id': id,
        'body': body,
      },
    );

    return MessageModel.fromJson(json: Map<String, dynamic>.from(data['message']));

  }

  void disconnect() {

    _socket?.dispose();
    _socket = null;
    _token = null;
    _joined.clear();

  }

  String _kind({required ChatKind kind}) {

    return switch (kind) {
      ChatKind.user => 'user',
      ChatKind.classGroup => 'class',
      ChatKind.subject => 'subject',
    };

  }

  Future<io.Socket> _connected() async {

    final token = ApiClient.instance.token;
    if (token == null) {
      throw ApiException(
        message: 'Please log in again',
        statusCode: 401,
      );
    }

    if (_socket != null && _token == token) {
      if (_socket!.connected) {
        return _socket!;
      }
    } else {
      disconnect();
      _token = token;
      _socket = _open(token: token);
    }

    final socket = _socket!;
    if (socket.connected) {
      return socket;
    }

    final ready = Completer<void>();
    void onConnect(dynamic _) {

      if (!ready.isCompleted) {
        ready.complete();
      }

    }

    void onError(dynamic error) {

      if (!ready.isCompleted) {
        ready.completeError(ApiException(message: _describe(error: error)));
      }

    }

    socket
      ..once(
        'connect',
        onConnect,
      )
      ..once(
        'connect_error',
        onError,
      );
    if (!socket.active) {
      socket.connect();
    }

    try {
      await ready.future.timeout(_ackTimeout);
    } on TimeoutException {
      throw ApiException(message: 'Cannot reach the chat server');
    } finally {
      socket
        ..off(
          'connect',
          onConnect,
        )
        ..off(
          'connect_error',
          onError,
        );
    }

    return socket;

  }

  io.Socket _open({required String token}) {

    final socket = io.io(
      Env.apiBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    socket.on('chat:message', (payload) {

      final data = Map<String, dynamic>.from(payload as Map);
      _live.add(
        LiveMessage(
          key: data['key'] as String,
          message: MessageModel.fromJson(
            json: Map<String, dynamic>.from(data['message']),
          ),
        ),
      );

    });

    socket.on('connect', (_) {

      for (final (kind, id) in _joined.toList()) {
        socket.emit(
          'chat:join', {
          'kind': _kind(kind: kind),
          'id': id,
        });
      }

    });

    return socket;

  }

  Future<Map<String, dynamic>> _request({
    required String event,
    required Map<String, dynamic> payload,
  }) async {

    final socket = await _connected();
    final reply = Completer<dynamic>();

    socket.emitWithAck(
      event,
      payload,
      ack: (response) {

        if (!reply.isCompleted) {
          reply.complete(response);
        }

      },
    );

    final response = await reply.future.timeout(
      _ackTimeout,
      onTimeout: () => throw ApiException(message: 'The chat server did not answer'),
    );
    final result = Map<String, dynamic>.from(response as Map);

    if (result['status'] != true) {
      throw ApiException(
        message: result['message'] as String? ?? 'Something went wrong',
      );
    }

    return Map<String, dynamic>.from(result['data'] as Map? ?? {});

  }

  String _describe({required dynamic error}) {

    final text = '$error';

    return text.contains('Please log in again') ? 'Please log in again' : text;

  }

}
