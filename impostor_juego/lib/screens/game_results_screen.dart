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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 70,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "FIN DEL JUEGO",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withOpacity(0.1),
                      blurRadius: 20,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.danger.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      impostors.length == 1
                          ? "EL IMPOSTOR ERA:"
                          : "LOS IMPOSTORES ERAN:",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...impostors.map(
                      (impostor) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              color: AppColors.danger,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              impostor.name,
                              style: TextStyle(
                                fontSize: 26,
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
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: "Jugar de nuevo",
                    color: AppColors.success,
                    onTap: () {
                      game.resetGame();
                      Navigator.pushReplacementNamed(context, '/reveal');
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.home,
                    label: "Inicio",
                    color: AppColors.primario,
                    onTap: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
