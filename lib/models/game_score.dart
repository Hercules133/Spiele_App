class GameScore {
  final int? id;
  final int gameId;
  final int playerId;
  final int round;
  final int score;
  final String? metadata; // JSON string für spielspezifische Daten

  GameScore({
    this.id,
    required this.gameId,
    required this.playerId,
    required this.round,
    required this.score,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'player_id': playerId,
      'round': round,
      'score': score,
      'metadata': metadata,
    };
  }

  factory GameScore.fromMap(Map<String, dynamic> map) {
    return GameScore(
      id: map['id'] as int?,
      gameId: map['game_id'] as int,
      playerId: map['player_id'] as int,
      round: map['round'] as int,
      score: map['score'] as int,
      metadata: map['metadata'] as String?,
    );
  }

  GameScore copyWith({
    int? id,
    int? gameId,
    int? playerId,
    int? round,
    int? score,
    String? metadata,
  }) {
    return GameScore(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      round: round ?? this.round,
      score: score ?? this.score,
      metadata: metadata ?? this.metadata,
    );
  }
}
