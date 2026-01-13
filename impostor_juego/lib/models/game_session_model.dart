import 'package:hive/hive.dart';
import 'player_model.dart';

part 'game_session_model.g.dart';

@HiveType(typeId: 2)
enum GameStatus {
  @HiveField(0)
  setup,
  @HiveField(1)
  playing,
  @HiveField(2)
  finished,
}

@HiveType(typeId: 3)
class GameSession {
  @HiveField(0)
  final String hostId;

  @HiveField(1)
  List<Player> players;

  @HiveField(2)
  int impostorCount;

  @HiveField(3)
  GameStatus status;

  GameSession({
    required this.hostId,
    required this.players,
    this.impostorCount = 1,
    this.status = GameStatus.setup,
  });

  Map<String, dynamic> toJson() => {
    'hostId': hostId,
    'players': players.map((p) => p.toJson()).toList(),
    'impostorCount': impostorCount,
    'status': status.index,
  };

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      hostId: json['hostId'],
      players:
          (json['players'] as List).map((i) => Player.fromJson(i)).toList(),
      impostorCount: json['impostorCount'],
      status: GameStatus.values[json['status']],
    );
  }
}
