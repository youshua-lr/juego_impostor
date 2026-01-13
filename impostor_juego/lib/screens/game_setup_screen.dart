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
      appBar: AppBar(
        title: const Text("Configurar Partida"),
        centerTitle: true,
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          return Column(
            children: [
              // Player input
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          onSubmitted: (_) => _addPlayer(),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _addPlayer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                                size: 60,
                                color: AppColors.secondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Agrega al menos 3 jugadores",
                                style: TextStyle(color: AppColors.secondary),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: game.players.length,
                          itemBuilder: (context, index) {
                            final player = game.players[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primario,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  player.name,
                                  style: TextStyle(
                                    color: AppColors.texto,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.danger,
                                  ),
                                  onPressed: () => game.removePlayer(player.id),
                                ),
                              ),
                            );
                          },
                        ),
              ),

              // Settings panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_off, color: AppColors.danger),
                            const SizedBox(width: 12),
                            Text(
                              "Impostores:",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.texto,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.fondo,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButton<int>(
                            value: _impostorCount,
                            underline: const SizedBox(),
                            style: TextStyle(
                              color: AppColors.texto,
                              fontSize: 18,
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              game.players.length >= 3
                                  ? AppColors.primario
                                  : AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                              ? "NECESITAS ${3 - game.players.length} JUGADOR(ES) MÁS"
                              : "¡COMENZAR JUEGO!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
