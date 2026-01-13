import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player_model.dart';
import '../services/game_data_service.dart';
import '../main.dart';

class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  int _currentPlayerIndex = 0;
  bool _isRevealed = false;
  bool _isLoading = true;

  WordData? _wordData;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    await GameDataService.loadData();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final category = args?['category'] as String?;
    _wordData = GameDataService.getRandomWord(category: category);
    setState(() => _isLoading = false);
  }

  void _reveal() {
    setState(() => _isRevealed = true);
  }

  void _next() {
    final game = context.read<GameProvider>();
    if (_currentPlayerIndex < game.players.length - 1) {
      setState(() {
        _currentPlayerIndex++;
        _isRevealed = false;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _showHint = args?['showHint'] ?? false;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.fondo,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primario),
        ),
      );
    }

    final game = context.watch<GameProvider>();

    if (game.players.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.fondo,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                "No hay jugadores",
                style: TextStyle(color: AppColors.texto),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    () => Navigator.popUntil(context, ModalRoute.withName('/')),
                child: const Text("Volver"),
              ),
            ],
          ),
        ),
      );
    }

    final currentPlayer = game.players[_currentPlayerIndex];
    final isImpostor = currentPlayer.role == Role.impostor;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(game.players.length, (i) {
                  return Container(
                    width: 28,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color:
                          i <= _currentPlayerIndex
                              ? AppColors.primario
                              : AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              Text(
                "Jugador ${_currentPlayerIndex + 1} de ${game.players.length}",
                style: TextStyle(fontSize: 12, color: AppColors.secondary),
              ),

              if (_wordData != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primario.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _wordData!.categoria,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Player card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Pasa el teléfono a:",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentPlayer.name,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (!_isRevealed)
                Column(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 40,
                      color: AppColors.secondary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primario,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _reveal,
                        child: const Text(
                          "Revelar mi rol",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        isImpostor
                            ? AppColors.danger.withOpacity(0.05)
                            : AppColors.success.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isImpostor
                              ? AppColors.danger.withOpacity(0.3)
                              : AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isImpostor
                                  ? AppColors.danger.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isImpostor ? Icons.person_off : Icons.person,
                          size: 40,
                          color:
                              isImpostor ? AppColors.danger : AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isImpostor ? "IMPOSTOR" : "CIUDADANO",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              isImpostor ? AppColors.danger : AppColors.success,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (_wordData != null) ...[
                        if (!isImpostor)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "La palabra es:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _wordData!.palabra,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.texto,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_showHint)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      size: 16,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Tu pista:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _wordData!.pista,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.texto,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  size: 24,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "¡No sabes la palabra!\nFinge conocerla.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.danger,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primario,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _next,
                          child: Text(
                            _currentPlayerIndex < game.players.length - 1
                                ? "Siguiente jugador"
                                : "¡A jugar!",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
