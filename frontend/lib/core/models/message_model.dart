class MessageModel {

  final int id;
  final int senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
  });

  factory MessageModel.fromJson({required Map<String, dynamic> json}) => MessageModel(
    id: json['id'],
    senderId: json['sender_id'],
    senderName: json['sender_name'],
    body: json['body'],
    createdAt: DateTime.parse(json['created_at']).toLocal(),
  );

}
