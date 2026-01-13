import 'dart:math';
import '../models/player_model.dart';

class GameLogicService {
  /// Assigns roles to players randomly.
  /// Returns a new list of players with updated roles.
  static List<Player> assignRoles(List<Player> players, int impostorCount) {
    if (players.isEmpty) return [];
    if (impostorCount >= players.length) {
      throw Exception("Too many impostors for player count");
    }

    final random = Random();
    // Create a copy to avoid mutating original list wrapper if unmodifiable
    List<Player> shuffledPlayers = List.from(players);

    // Reset all to citizen first
    for (var p in shuffledPlayers) {
      p.role = Role.citizen;
    }

    // Assign impostors
    int assigned = 0;
    while (assigned < impostorCount) {
      int index = random.nextInt(shuffledPlayers.length);
      if (shuffledPlayers[index].role != Role.impostor) {
        shuffledPlayers[index].role = Role.impostor;
        assigned++;
      }
    }

    // Shuffle the list itself just in case order matters somewhere,
    // though role assignment was already random index based.
    shuffledPlayers.shuffle(random);

    return shuffledPlayers;
  }
}
