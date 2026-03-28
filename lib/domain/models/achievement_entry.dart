class AchievementEntry {
  const AchievementEntry({
    required this.id,
    required this.countdownId,
    required this.entryDate,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String countdownId;
  final DateTime entryDate;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  AchievementEntry copyWith({
    String? id,
    String? countdownId,
    DateTime? entryDate,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AchievementEntry(
      id: id ?? this.id,
      countdownId: countdownId ?? this.countdownId,
      entryDate: entryDate ?? this.entryDate,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'countdown_id': countdownId,
      'entry_date': entryDate.toIso8601String(),
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AchievementEntry.fromMap(Map<String, Object?> map) {
    return AchievementEntry(
      id: map['id']! as String,
      countdownId: map['countdown_id']! as String,
      entryDate: DateTime.parse(map['entry_date']! as String),
      content: map['content']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }
}
