class GamePlayer {
  final int? id;
  final int gameId;
  final int playerId;
  final int playerOrder;
  final int totalScore;

  GamePlayer({
    this.id,
    required this.gameId,
    required this.playerId,
    required this.playerOrder,
    this.totalScore = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'player_id': playerId,
      'player_order': playerOrder,
      'total_score': totalScore,
    };
  }

  factory GamePlayer.fromMap(Map<String, dynamic> map) {
    return GamePlayer(
      id: map['id'] as int?,
      gameId: map['game_id'] as int,
      playerId: map['player_id'] as int,
      playerOrder: map['player_order'] as int,
      totalScore: map['total_score'] as int? ?? 0,
    );
  }

  GamePlayer copyWith({
    int? id,
    int? gameId,
    int? playerId,
    int? playerOrder,
    int? totalScore,
  }) {
    return GamePlayer(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      playerOrder: playerOrder ?? this.playerOrder,
      totalScore: totalScore ?? this.totalScore,
    );
  }
}
