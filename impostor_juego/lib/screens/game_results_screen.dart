import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player_model.dart';
import '../main.dart';

class GameResultsScreen extends StatelessWidget {
  const GameResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final impostors =
        game.players.where((p) => p.role == Role.impostor).toList();

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Trophy icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 50,
                  color: AppColors.warning,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Fin del Juego",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                ),
              ),

              const Spacer(),

              // Impostor reveal card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      impostors.length == 1
                          ? "El impostor era:"
                          : "Los impostores eran:",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...impostors.map(
                      (impostor) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_off,
                              color: AppColors.danger,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              impostor.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primario),
                      ),
                      onPressed: () {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, color: AppColors.primario, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Inicio",
                            style: TextStyle(
                              color: AppColors.primario,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        game.resetGame();
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                        Navigator.pushNamed(context, '/setup');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Jugar otra",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
