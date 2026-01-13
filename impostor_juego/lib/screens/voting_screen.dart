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
    if (game.players.isEmpty) return 0;
    return _readyPlayers.length / game.players.length;
  }

  void _markReady(String playerId) {
    setState(() {
      _readyPlayers.add(playerId);
      if (readyPercentage >= 0.7) {
        _showVotingPhase = true;
      }
    });
  }

  void _castVote(String votedPlayerId) {
    setState(() {
      _votes[votedPlayerId] = (_votes[votedPlayerId] ?? 0) + 1;
      _votedImpostor = votedPlayerId;
    });

    final game = context.read<GameProvider>();

    // Move to next voter or finish
    if (_currentVotingPlayer < game.players.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentVotingPlayer++;
          _votedImpostor = null;
        });
      });
    } else {
      // Voting complete - go to results
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/results');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (!_showVotingPhase) {
      // Ready phase
      return Scaffold(
        backgroundColor: AppColors.fondo,
        appBar: AppBar(
          title: const Text("Fase de Votación"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              "¿Listos para votar?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.texto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Se necesita 70% para iniciar",
              style: TextStyle(color: AppColors.secondary),
            ),
            const SizedBox(height: 30),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: readyPercentage,
                      minHeight: 20,
                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        readyPercentage >= 0.7
                            ? AppColors.success
                            : AppColors.primario,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(readyPercentage * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Player list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: game.players.length,
                itemBuilder: (context, index) {
                  final player = game.players[index];
                  final isReady = _readyPlayers.contains(player.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isReady
                                ? AppColors.success
                                : AppColors.secondary.withOpacity(0.3),
                        child: Icon(
                          isReady ? Icons.check : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          color: AppColors.texto,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing:
                          isReady
                              ? Chip(
                                label: const Text(
                                  "LISTO",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: AppColors.success,
                              )
                              : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primario,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                onPressed: () => _markReady(player.id),
                                child: const Text(
                                  "Listo",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Voting phase
    final currentVoter = game.players[_currentVotingPlayer];

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text("¡Voten!"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primario.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              "Turno de: ${currentVoter.name}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primario,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "¿Quién crees que es el impostor?",
            style: TextStyle(color: AppColors.secondary),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: game.players.length,
              itemBuilder: (context, index) {
                final player = game.players[index];
                final isCurrentVoter = player.id == currentVoter.id;
                final isVoted = _votedImpostor == player.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isCurrentVoter ? null : () => _castVote(player.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isVoted
                                  ? AppColors.danger.withOpacity(0.1)
                                  : (isCurrentVoter
                                      ? AppColors.secondary.withOpacity(0.1)
                                      : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isVoted
                                    ? AppColors.danger
                                    : (isCurrentVoter
                                        ? AppColors.secondary.withOpacity(0.3)
                                        : Colors.transparent),
                            width: 2,
                          ),
                          boxShadow:
                              isCurrentVoter
                                  ? null
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                    ),
                                  ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  isCurrentVoter
                                      ? AppColors.secondary
                                      : AppColors.primario,
                              child: Text(
                                player.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                player.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isCurrentVoter
                                          ? AppColors.secondary
                                          : AppColors.texto,
                                ),
                              ),
                            ),
                            if (isCurrentVoter)
                              Text(
                                "(Tú)",
                                style: TextStyle(color: AppColors.secondary),
                              )
                            else if (isVoted)
                              Icon(Icons.how_to_vote, color: AppColors.danger),
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
    );
  }
}
