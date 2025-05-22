import 'dart:convert';

/// Uygulamadaki notları temsil eden veri modeli.
class Note {
  /// JSON formatındaki bir Map'ten yeni bir [Note] örneği oluşturur.
  /// Geçersiz formatta bir Map verilirse [FormatException] fırlatır.
  factory Note.fromJson(Map<String, dynamic> json) {
    if (json case {
      'id': String id,
      'title': String title,
      'content': String content,
      'createdAt': String createdAt,
    }) {
      return Note(
        id: id,
        title: title,
        content: content,
        createdAt: DateTime.parse(createdAt),
      );
    }
    throw FormatException('Geçersiz Note json formatı: $json');
  }

  /// Notun benzersiz kimliği.
  final String id;

  /// Notun başlığı.
  final String title;

  /// Notun içeriği.
  final String content;

  /// Notun oluşturulma tarihi ve saati.
  final DateTime createdAt;

  /// Yeni bir [Note] örneği oluşturur.
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ content.hashCode ^ createdAt.hashCode;
  }

  /// Not nesnesinin yeni veya güncellenmiş alanlarla bir kopyasını oluşturur.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Not nesnesini JSON formatına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
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
