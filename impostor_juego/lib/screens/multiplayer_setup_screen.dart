import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/game_provider.dart';
import '../main.dart';

class MultiplayerInitScreen extends StatelessWidget {
  const MultiplayerInitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(title: const Text("Modo Multijugador"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primario.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.wifi, size: 60, color: AppColors.primario),
              ),
              const SizedBox(height: 30),
              Text(
                "Juega en la misma red WiFi",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Asegúrate de que todos los dispositivos estén conectados a la misma red",
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              _buildOptionCard(
                context,
                icon: Icons.add_circle_outline,
                title: "Crear Partida",
                subtitle: "Sé el anfitrión del juego",
                color: AppColors.primario,
                onTap: () => Navigator.pushNamed(context, '/multi_host'),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: Icons.login,
                title: "Unirse a Partida",
                subtitle: "Únete a un juego existente",
                color: AppColors.success,
                onTap: () => Navigator.pushNamed(context, '/multi_join'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class HostLobbyScreen extends StatefulWidget {
  const HostLobbyScreen({super.key});

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _joined = false;
  int _impostorCount = 1;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startHosting();
    });
  }

  void _joinAsHost() {
    if (_nameController.text.trim().isNotEmpty) {
      context.read<GameProvider>().addPlayer(_nameController.text.trim());
      setState(() => _joined = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.isGameActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              '/category',
              arguments: {'showHint': _showHint},
            );
          });
        }

        return Scaffold(
          backgroundColor: AppColors.fondo,
          appBar: AppBar(
            title: const Text("Sala de Espera"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // QR Code Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Código de la Sala",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (game.hostAddress != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.2),
                            ),
                          ),
                          child: QrImageView(
                            data: game.hostAddress!,
                            version: QrVersions.auto,
                            size: 160.0,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.texto,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.texto,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primario.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wifi,
                                color: AppColors.primario,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                game.hostAddress!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primario,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        CircularProgressIndicator(color: AppColors.primario),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Join as host
                if (!_joined)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Ingresa tu nombre",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                style: TextStyle(color: AppColors.texto),
                                decoration: InputDecoration(
                                  hintText: "Tu nombre",
                                  hintStyle: TextStyle(
                                    color: AppColors.secondary,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.fondo,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              onPressed: _joinAsHost,
                              child: const Text("Unirme"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Players list
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Jugadores",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                              "${game.players.length} conectados",
                              style: TextStyle(
                                color: AppColors.primario,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (game.players.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "Esperando jugadores...",
                              style: TextStyle(color: AppColors.secondary),
                            ),
                          ),
                        )
                      else
                        ...game.players.map(
                          (player) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.fondo,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primario,
                                  radius: 16,
                                  child: Text(
                                    player.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  player.name,
                                  style: TextStyle(
                                    color: AppColors.texto,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (player.id == game.myPlayerId)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Tú",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Settings
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_off,
                                color: AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Impostores",
                                style: TextStyle(color: AppColors.texto),
                              ),
                            ],
                          ),
                          DropdownButton<int>(
                            value: _impostorCount,
                            underline: const SizedBox(),
                            items:
                                List.generate(3, (i) => i + 1)
                                    .map(
                                      (i) => DropdownMenuItem(
                                        value: i,
                                        child: Text("$i"),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _impostorCount = val);
                                game.updateImpostorCount(val);
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Pista para impostor",
                                style: TextStyle(color: AppColors.texto),
                              ),
                            ],
                          ),
                          Switch(
                            value: _showHint,
                            onChanged: (val) => setState(() => _showHint = val),
                            activeColor: AppColors.primario,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          game.players.length >= 2
                              ? AppColors.success
                              : AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        game.players.length >= 2
                            ? () {
                              game.updateImpostorCount(_impostorCount);
                              game.startGame();
                            }
                            : null,
                    child: Text(
                      game.players.length < 2
                          ? "Esperando más jugadores..."
                          : "¡INICIAR PARTIDA!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ClientJoinScreen extends StatefulWidget {
  const ClientJoinScreen({super.key});

  @override
  State<ClientJoinScreen> createState() => _ClientJoinScreenState();
}

class _ClientJoinScreenState extends State<ClientJoinScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isConnecting = false;

  void _join() async {
    if (_ipController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _isConnecting = true);
    try {
      await context.read<GameProvider>().joinGame(
        _ipController.text.trim(),
        _nameController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/multi_client_lobby');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
      }
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(title: const Text("Unirse a Partida"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.login, size: 50, color: AppColors.success),
            ),

            const SizedBox(height: 30),

            // Name input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tu Nombre",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: AppColors.texto, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Ingresa tu nombre",
                      hintStyle: TextStyle(color: AppColors.secondary),
                      prefixIcon: Icon(
                        Icons.person,
                        color: AppColors.secondary,
                      ),
                      filled: true,
                      fillColor: AppColors.fondo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // IP input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Código de la Sala",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ipController,
                    style: TextStyle(color: AppColors.texto, fontSize: 18),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "192.168.X.X",
                      hintStyle: TextStyle(color: AppColors.secondary),
                      prefixIcon: Icon(Icons.wifi, color: AppColors.secondary),
                      filled: true,
                      fillColor: AppColors.fondo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const ScannerScreen(),
                        ),
                      );
                      if (result != null) {
                        _ipController.text = result;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primario.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primario,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Escanear código QR",
                            style: TextStyle(
                              color: AppColors.primario,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Connect button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isConnecting ? null : _join,
                child:
                    _isConnecting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "CONECTAR",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Escanear Código"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(context, barcode.rawValue);
                  return;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primario, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Apunta al código QR del anfitrión",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClientLobbyScreen extends StatelessWidget {
  const ClientLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.isGameActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/reveal');
          });
        }

        return Scaffold(
          backgroundColor: AppColors.fondo,
          appBar: AppBar(
            title: const Text("Sala de Espera"),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "¡Conectado!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Esperando a que el anfitrión inicie la partida...",
                    style: TextStyle(fontSize: 14, color: AppColors.secondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Players
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Jugadores en la sala",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...game.players.map(
                          (player) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.fondo,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primario,
                                  radius: 16,
                                  child: Text(
                                    player.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  player.name,
                                  style: TextStyle(
                                    color: AppColors.texto,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (player.id == game.myPlayerId)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Tú",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Loading indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.primario,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Esperando...",
                        style: TextStyle(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
