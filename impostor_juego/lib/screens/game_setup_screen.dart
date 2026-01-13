import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../main.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _impostorCount = 1;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      _showHint = args?['showHint'] ?? false;
      context.read<GameProvider>().initSession("local_host");
    });
  }

  void _addPlayer() {
    if (_nameController.text.trim().isNotEmpty) {
      context.read<GameProvider>().addPlayer(_nameController.text.trim());
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, game, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: AppColors.texto),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Configurar Partida",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.texto,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      "Agrega los jugadores",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Player input card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: TextStyle(color: AppColors.texto),
                            decoration: InputDecoration(
                              hintText: "Nombre del jugador",
                              hintStyle: TextStyle(color: AppColors.secondary),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.secondary,
                              ),
                            ),
                            onSubmitted: (_) => _addPlayer(),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _addPlayer,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Player count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jugadores",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.texto,
                        ),
                      ),
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
                          "${game.players.length} de 3 mínimo",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primario,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Player list
                  Expanded(
                    child:
                        game.players.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 48,
                                    color: AppColors.secondary.withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Sin jugadores aún",
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: game.players.length,
                              itemBuilder: (context, index) {
                                final player = game.players[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.secondary.withOpacity(
                                        0.15,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.primario.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${index + 1}",
                                            style: TextStyle(
                                              color: AppColors.primario,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          player.name,
                                          style: TextStyle(
                                            color: AppColors.texto,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: AppColors.danger,
                                          size: 20,
                                        ),
                                        onPressed:
                                            () => game.removePlayer(player.id),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),

                  // Settings card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_off,
                                color: AppColors.danger,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Impostores",
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.texto,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.fondo,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButton<int>(
                            value: _impostorCount,
                            underline: const SizedBox(),
                            style: TextStyle(
                              color: AppColors.texto,
                              fontSize: 16,
                            ),
                            items:
                                List.generate(3, (i) => i + 1).map((i) {
                                  return DropdownMenuItem(
                                    value: i,
                                    child: Text("$i"),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _impostorCount = val);
                                game.updateImpostorCount(val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            game.players.length >= 3
                                ? AppColors.primario
                                : AppColors.secondary.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          game.players.length >= 3
                              ? () {
                                game.updateImpostorCount(_impostorCount);
                                game.startGame();
                                Navigator.pushNamed(
                                  context,
                                  '/category',
                                  arguments: {'showHint': _showHint},
                                );
                              }
                              : null,
                      child: Text(
                        game.players.length < 3
                            ? "Faltan ${3 - game.players.length} jugador(es)"
                            : "Continuar",
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
            );
          },
        ),
      ),
    );
  }
}
