class Countdown {
  const Countdown({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    this.note,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String? note;
  final bool isPinned;

  Countdown copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? note,
    bool? isPinned,
    bool clearNote = false,
  }) {
    return Countdown(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      note: clearNote ? null : (note ?? this.note),
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'target_date': targetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
      'note': note,
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  factory Countdown.fromMap(Map<String, Object?> map) {
    return Countdown(
      id: map['id']! as String,
      title: map['title']! as String,
      targetDate: DateTime.parse(map['target_date']! as String),
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderHour: map['reminder_hour'] as int? ?? 9,
      reminderMinute: map['reminder_minute'] as int? ?? 0,
      note: map['note'] as String?,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
    );
  }
}
