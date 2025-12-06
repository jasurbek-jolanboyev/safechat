// lib/models/message/message.dart
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final int id;
  final String? text;
  final String? type; // "text", "image", "voice", "file"
  final String? attachment; // rasm yoki fayl yoʻli (local yoki URL)
  final String? voice; // ovozli xabar fayl yoʻli
  final String createdAt;
  final bool isMe;

  const Message({
    required this.id,
    this.text,
    this.type = 'text',
    this.attachment,
    this.voice,
    required this.createdAt,
    required this.isMe,
  });

  // Nusxa olish
  Message copyWith({
    int? id,
    String? text,
    String? type,
    String? attachment,
    String? voice,
    String? createdAt,
    bool? isMe,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      attachment: attachment ?? this.attachment,
      voice: voice ?? this.voice,
      createdAt: createdAt ?? this.createdAt,
      isMe: isMe ?? this.isMe,
    );
  }

  // JSON dan oʻqish
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"] ?? DateTime.now().millisecondsSinceEpoch,
      text: json["text"],
      type: json["type"] ?? "text",
      attachment: json["attachment"],
      voice: json["voice"],
      createdAt: json["createdAt"] ?? "Hozir",
      isMe: json["isMe"] ?? false,
    );
  }

  // JSON ga yozish
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "text": text,
      "type": type,
      "attachment": attachment,
      "voice": voice,
      "createdAt": createdAt,
      "isMe": isMe,
    };
  }

  @override
  List<Object?> get props => [
    id,
    text,
    type,
    attachment,
    voice,
    createdAt,
    isMe,
  ];
}
