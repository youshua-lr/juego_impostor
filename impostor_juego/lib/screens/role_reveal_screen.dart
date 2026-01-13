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

class _RoleRevealScreenState extends State<RoleRevealScreen>
    with SingleTickerProviderStateMixin {
  int _currentPlayerIndex = 0;
  bool _isRevealed = false;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  WordData? _wordData;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _loadGameData();
  }

  Future<void> _loadGameData() async {
    await GameDataService.loadData();
    // Get category from arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final category = args?['category'] as String?;
    _wordData = GameDataService.getRandomWord(category: category);
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _reveal() {
    setState(() => _isRevealed = true);
    _animController.forward(from: 0);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primario),
              const SizedBox(height: 20),
              Text(
                "Cargando datos...",
                style: TextStyle(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      );
    }

    final game = context.watch<GameProvider>();

    // Safety check - if no players, go back
    if (game.players.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.fondo,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: AppColors.danger),
              const SizedBox(height: 20),
              Text(
                "Error: No hay jugadores",
                style: TextStyle(color: AppColors.texto, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    () => Navigator.popUntil(context, ModalRoute.withName('/')),
                child: const Text("Volver al inicio"),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(game.players.length, (i) {
                    return Container(
                      width: 24,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            i <= _currentPlayerIndex
                                ? AppColors.primario
                                : AppColors.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),

              // Category badge
              if (_wordData != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primario.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _wordData!.categoria,
                    style: TextStyle(
                      color: AppColors.primario,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const Spacer(),

              // Player name
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Text(
                  currentPlayer.name,
                  style: TextStyle(
                    color: AppColors.texto,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              if (!_isRevealed)
                Column(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 60,
                      color: AppColors.secondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primario,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _reveal,
                      child: const Text(
                        "REVELAR ROL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                )
              else
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isImpostor
                                  ? AppColors.danger.withOpacity(0.1)
                                  : AppColors.primario.withOpacity(0.1),
                          border: Border.all(
                            color:
                                isImpostor
                                    ? AppColors.danger
                                    : AppColors.primario,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          isImpostor ? Icons.person_off : Icons.person,
                          size: 70,
                          color:
                              isImpostor
                                  ? AppColors.danger
                                  : AppColors.primario,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isImpostor ? "IMPOSTOR" : "CIUDADANO",
                        style: TextStyle(
                          color:
                              isImpostor
                                  ? AppColors.danger
                                  : AppColors.primario,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (_wordData != null) ...[
                        if (!isImpostor)
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primario.withOpacity(0.1),
                                  blurRadius: 15,
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.primario.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "LA PALABRA ES:",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _wordData!.palabra,
                                  style: TextStyle(
                                    color: AppColors.texto,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else if (isImpostor && _showHint)
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.warning.withOpacity(0.2),
                                  blurRadius: 15,
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "TU PISTA:",
                                      style: TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 12,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _wordData!.pista,
                                  style: TextStyle(
                                    color: AppColors.texto,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else if (isImpostor && !_showHint)
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.danger.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: AppColors.danger,
                                  size: 36,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No tienes información.\n¡Finge conocer la palabra!",
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                      ],

                      const SizedBox(height: 30),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _next,
                        child: Text(
                          _currentPlayerIndex < game.players.length - 1
                              ? "SIGUIENTE JUGADOR"
                              : "¡A JUGAR!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
