import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/game_player.dart';
import '../models/game_score.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  String? dbFileOverride;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final fileName = dbFileOverride ?? 'spiele_app.db';
    _database = await _initDB(fileName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (filePath == ':memory:') {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_type TEXT NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE game_players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id INTEGER NOT NULL,
        player_id INTEGER NOT NULL,
        player_order INTEGER NOT NULL,
        total_score INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
        FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE game_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id INTEGER NOT NULL,
        player_id INTEGER NOT NULL,
        round INTEGER NOT NULL,
        score INTEGER NOT NULL,
        metadata TEXT,
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
        FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
      )
    ''');
  }

  // Player CRUD Operations
  Future<int> createPlayer(Player player) async {
    final db = await database;
    return await db.insert('players', player.toMap());
  }

  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final result = await db.query('players', orderBy: 'name ASC');
    return result.map((map) => Player.fromMap(map)).toList();
  }

  Future<Player?> getPlayer(int id) async {
    final db = await database;
    final result = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Player.fromMap(result.first);
  }

  Future<int> updatePlayer(Player player) async {
    final db = await database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(int id) async {
    final db = await database;
    return await db.delete(
      'players',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Game CRUD Operations
  Future<int> createGame(Game game) async {
    final db = await database;
    return await db.insert('games', game.toMap());
  }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final result = await db.query('games', orderBy: 'started_at DESC');
    return result.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<Game>> getGamesByType(GameType gameType) async {
    final db = await database;
    final result = await db.query(
      'games',
      where: 'game_type = ?',
      whereArgs: [gameType.name],
      orderBy: 'started_at DESC',
    );
    return result.map((map) => Game.fromMap(map)).toList();
  }

  Future<Game?> getGame(int id) async {
    final db = await database;
    final result = await db.query(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Game.fromMap(result.first);
  }

  Future<int> updateGame(Game game) async {
    final db = await database;
    return await db.update(
      'games',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<int> deleteGame(int id) async {
    final db = await database;
    return await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GamePlayer CRUD Operations
  Future<int> createGamePlayer(GamePlayer gamePlayer) async {
    final db = await database;
    return await db.insert('game_players', gamePlayer.toMap());
  }

  Future<List<GamePlayer>> getGamePlayers(int gameId) async {
    final db = await database;
    final result = await db.query(
      'game_players',
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'player_order ASC',
    );
    return result.map((map) => GamePlayer.fromMap(map)).toList();
  }

  Future<int> updateGamePlayer(GamePlayer gamePlayer) async {
    final db = await database;
    return await db.update(
      'game_players',
      gamePlayer.toMap(),
      where: 'id = ?',
      whereArgs: [gamePlayer.id],
    );
  }

  // GameScore CRUD Operations
  Future<int> createGameScore(GameScore gameScore) async {
    final db = await database;
    return await db.insert('game_scores', gameScore.toMap());
  }

  Future<List<GameScore>> getGameScores(int gameId) async {
    final db = await database;
    final result = await db.query(
      'game_scores',
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'round ASC, player_id ASC',
    );
    return result.map((map) => GameScore.fromMap(map)).toList();
  }

  Future<List<GameScore>> getPlayerScoresForGame(
      int gameId, int playerId) async {
    final db = await database;
    final result = await db.query(
      'game_scores',
      where: 'game_id = ? AND player_id = ?',
      whereArgs: [gameId, playerId],
      orderBy: 'round ASC',
    );
    return result.map((map) => GameScore.fromMap(map)).toList();
  }

  Future<int> updateGameScore(GameScore gameScore) async {
    final db = await database;
    return await db.update(
      'game_scores',
      gameScore.toMap(),
      where: 'id = ?',
      whereArgs: [gameScore.id],
    );
  }

  Future<int> deleteGameScore(int id) async {
    final db = await database;
    return await db.delete(
      'game_scores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Combined queries for leaderboards
  Future<List<Map<String, dynamic>>> getLeaderboard(GameType gameType) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        p.id as player_id,
        p.name as player_name,
        COUNT(DISTINCT g.id) as games_played,
        AVG(gp.total_score) as avg_score,
        MIN(gp.total_score) as best_score,
        MAX(gp.total_score) as worst_score
      FROM players p
      INNER JOIN game_players gp ON p.id = gp.player_id
      INNER JOIN games g ON gp.game_id = g.id
      WHERE g.game_type = ? AND g.is_completed = 1
      GROUP BY p.id, p.name
      ORDER BY avg_score ASC
    ''', [gameType.name]);
    return result;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
