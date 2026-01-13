import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player_model.dart';
import '../main.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final Set<String> _readyPlayers = {};
  int _currentVotingPlayer = 0;
  bool _showVotingPhase = false;
  String? _votedImpostor;
  final Map<String, int> _votes = {};

  double get readyPercentage {
    final game = context.read<GameProvider>();
    final alivePlayers = game.players.where((p) => p.isAlive).length;
    if (alivePlayers == 0) return 0;
    return _readyPlayers.length / alivePlayers;
  }

  void _markReady(String playerId) {
    setState(() {
      _readyPlayers.add(playerId);
      if (readyPercentage >= 0.7) {
        _startVotingPhase();
      }
    });
  }

  void _startVotingPhase() {
    final game = context.read<GameProvider>();
    // Find first alive player
    int firstAlive = game.players.indexWhere((p) => p.isAlive);
    if (firstAlive != -1) {
      _showVotingPhase = true;
      _currentVotingPlayer = firstAlive;
    }
  }

  void _castVote(String votedPlayerId) {
    setState(() {
      _votes[votedPlayerId] = (_votes[votedPlayerId] ?? 0) + 1;
      _votedImpostor = votedPlayerId;
    });

    final game = context.read<GameProvider>();

    // Find next alive player
    int nextPlayer = _currentVotingPlayer + 1;
    while (nextPlayer < game.players.length &&
        !game.players[nextPlayer].isAlive) {
      nextPlayer++;
    }

    if (nextPlayer < game.players.length) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentVotingPlayer = nextPlayer;
          _votedImpostor = null;
        });
      });
    } else {
      // All alive players voted
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleVotingResult(game);
      });
    }
  }

  void _handleVotingResult(GameProvider game) {
    if (_votes.isEmpty) return;

    // Calculate max votes
    String? ejectedId;
    int maxVotes = 0;

    _votes.forEach((playerId, count) {
      if (count > maxVotes) {
        maxVotes = count;
        ejectedId = playerId;
      }
    });

    // Check for tie (simple implementation: if tie, just pick one or none?
    // For now assuming the one found first is ejected, or improvements can be made)
    // Actually let's check if there is a tie for max
    int playersWithMaxVotes = 0;
    _votes.forEach((_, count) {
      if (count == maxVotes) playersWithMaxVotes++;
    });

    if (playersWithMaxVotes > 1) {
      // Tie - No one ejected
      _showResultDialog(null, false);
      return;
    }

    if (ejectedId != null) {
      final ejectedPlayer = game.players.firstWhere((p) => p.id == ejectedId);
      final isImpostor = ejectedPlayer.role == Role.impostor;

      if (isImpostor) {
        // Impostor found - Go to results
        Navigator.pushReplacementNamed(context, '/results');
      } else {
        // Not impostor - Show dialog and return to game
        _showResultDialog(ejectedPlayer, false);
      }
    }
  }

  void _showResultDialog(Player? player, bool isImpostor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            player == null ? "Empate" : "Resultado",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (player != null) ...[
                Icon(Icons.person_off, size: 50, color: AppColors.secondary),
                const SizedBox(height: 16),
                Text(
                  "${player.name} fue expulsado.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "NO ERA EL IMPOSTOR",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ] else
                Text("Nadie fue expulsado (Empate)."),

              const SizedBox(height: 20),
              Text(
                "El juego continúa...",
                style: TextStyle(color: AppColors.secondary),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(
                    context,
                    '/game',
                  ); // Back to game
                },
                child: const Text(
                  "Continuar Jugando",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (!_showVotingPhase) {
      // Ready phase
      return Scaffold(
        backgroundColor: AppColors.fondo,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "¿Listos para Votar?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Esperando a los jugadores vivos...",
                  style: TextStyle(fontSize: 14, color: AppColors.secondary),
                ),

                const SizedBox(height: 30),

                // Progress card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: readyPercentage,
                          minHeight: 12,
                          backgroundColor: AppColors.secondary.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            readyPercentage >= 0.7
                                ? AppColors.success
                                : AppColors.primario,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${(readyPercentage * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texto,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Players list
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      final isReady = _readyPlayers.contains(player.id);
                      final isAlive = player.isAlive;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isAlive
                                  ? Colors.white
                                  : AppColors.secondary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                    isAlive
                                        ? (isReady
                                            ? AppColors.success.withOpacity(0.1)
                                            : AppColors.fondo)
                                        : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isAlive
                                    ? (isReady
                                        ? Icons.check
                                        : Icons.person_outline)
                                    : Icons.cancel_outlined,
                                color:
                                    isAlive
                                        ? (isReady
                                            ? AppColors.success
                                            : AppColors.secondary)
                                        : Colors.grey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                player.name,
                                style: TextStyle(
                                  color:
                                      isAlive ? AppColors.texto : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  decoration:
                                      isAlive
                                          ? null
                                          : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            if (!isAlive)
                              Text(
                                "Eliminado",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                            else if (isReady)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Listo",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else
                              TextButton(
                                onPressed: () => _markReady(player.id),
                                child: Text(
                                  "Marcar listo",
                                  style: TextStyle(
                                    color: AppColors.primario,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Voting phase
    final currentVoter = game.players[_currentVotingPlayer];

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Votación",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "¿Quién es el impostor?",
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
              ),

              const SizedBox(height: 24),

              // Current voter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primario.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Turno de: ${currentVoter.name}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primario,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Players to vote
              Expanded(
                child: ListView.builder(
                  itemCount: game.players.length,
                  itemBuilder: (context, index) {
                    final player = game.players[index];
                    final isCurrentVoter = player.id == currentVoter.id;
                    final isVoted = _votedImpostor == player.id;
                    final isAlive = player.isAlive;

                    final bool canVoteThisPlayer = !isCurrentVoter && isAlive;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              canVoteThisPlayer
                                  ? () => _castVote(player.id)
                                  : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isVoted
                                      ? AppColors.danger.withOpacity(0.1)
                                      : (isAlive
                                          ? Colors.white
                                          : Colors.grey.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isVoted
                                        ? AppColors.danger
                                        : AppColors.secondary.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        isAlive
                                            ? (isCurrentVoter
                                                ? AppColors.secondary
                                                    .withOpacity(0.1)
                                                : AppColors.primario
                                                    .withOpacity(0.1))
                                            : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child:
                                        isAlive
                                            ? Text(
                                              player.name[0].toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isCurrentVoter
                                                        ? AppColors.secondary
                                                        : AppColors.primario,
                                              ),
                                            )
                                            : Icon(
                                              Icons.close,
                                              color: Colors.grey,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isAlive
                                              ? (isCurrentVoter
                                                  ? AppColors.secondary
                                                  : AppColors.texto)
                                              : Colors.grey,
                                      decoration:
                                          isAlive
                                              ? null
                                              : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                                if (isCurrentVoter)
                                  Text(
                                    "(Tú)",
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 13,
                                    ),
                                  )
                                else if (isVoted)
                                  Icon(
                                    Icons.how_to_vote,
                                    color: AppColors.danger,
                                    size: 20,
                                  )
                                else if (!isAlive)
                                  Text(
                                    "Eliminado",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
