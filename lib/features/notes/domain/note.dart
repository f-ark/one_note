import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Uygulamadaki notları temsil eden veri modeli.
@immutable
class Note {
  /// Yeni bir [Note] örneği oluşturur.
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.userId,
  });

  /// JSON formatındaki bir Map'ten yeni bir [Note] örneği oluşturur.
  /// Geçersiz formatta bir Map verilirse [FormatException] fırlatır.
  factory Note.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': final String id,
      'title': final String title,
      'content': final String content,
      'createdAt': final String createdAt,
      'userId': final String userId,
    }) {
      return Note(
        id: id,
        title: title,
        content: content,
        createdAt: DateTime.parse(createdAt),
        userId: userId,
      );
    }
    throw FormatException('Geçersiz Note json formatı: $json');
  }

  /// Notun benzersiz kimliği.
  final String? id;

  /// Notun başlığı.
  final String title;

  /// Notun içeriği.
  final String content;

  /// Notun oluşturulma tarihi ve saati.
  final DateTime createdAt;

  final String userId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        userId.hashCode;
  }

  /// Not nesnesinin yeni veya güncellenmiş alanlarla bir kopyasını oluşturur.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  /// Not nesnesini JSON formatına dönüştürür.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// JSON formatındaki bir string'den [Note] listesi oluşturur.
  /// Geçersiz formatta bir string verilirse [FormatException] fırlatır.
  static List<Note> listFromJson(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      throw FormatException('Beklenen liste, gelen: ${decoded.runtimeType}');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Note.fromJson)
        .toList();
  }

  /// [Note] listesini JSON formatındaki bir string'e dönüştürür.
  static String listToJson(List<Note> notes) {
    return jsonEncode(notes.map((note) => note.toJson()).toList());
  }
}
