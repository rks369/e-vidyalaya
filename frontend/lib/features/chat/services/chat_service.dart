import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/models/message_model.dart';

enum ChatKind { user, classGroup, subject }

class ChatService {

  static String _path({
    required ChatKind kind,
    required int id,
  }) {

    final segment = switch (kind) {
      ChatKind.user => 'user',
      ChatKind.classGroup => 'class',
      ChatKind.subject => 'subject',
    };
    return '/chats/$segment/$id/messages';

  }

  static Future<List<MessageModel>> fetch({
    required ChatKind kind,
    required int id,
    int? afterId,
  }) async {

    final rows = await ApiClient.instance.get(
      path: _path(
        kind: kind,
        id: id,
      ),
      query: {if (afterId != null) 'after': '$afterId'},
    ) as List;
    return rows.map((row) => MessageModel.fromJson(json: row)).toList();

  }

}
