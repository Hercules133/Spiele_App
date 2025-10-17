enum GameType {
  skyjo,
  kniffel,
  wizard;

  String get displayName {
    switch (this) {
      case GameType.skyjo:
        return 'Skyjo';
      case GameType.kniffel:
        return 'Kniffel';
      case GameType.wizard:
        return 'Wizard';
    }
  }
}

class Game {
  final int? id;
  final GameType gameType;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;

  Game({
    this.id,
    required this.gameType,
    DateTime? startedAt,
    this.completedAt,
    this.isCompleted = false,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_type': gameType.name,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int?,
      gameType: GameType.values.firstWhere(
        (e) => e.name == map['game_type'],
      ),
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      isCompleted: map['is_completed'] == 1,
    );
  }

  Game copyWith({
    int? id,
    GameType? gameType,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isCompleted,
  }) {
    return Game(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
