import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showHintToImpostor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              Center(
                child: Column(
                  children: [
                    Text(
                      "Seleccionar Modo de Juego",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Elige cómo quieres jugar",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Single Device Card
              _buildModeCard(
                icon: Icons.phone_android,
                iconColor: AppColors.primario,
                title: "Un Dispositivo",
                subtitle: "Pasa el teléfono entre jugadores",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/setup',
                    arguments: {
                      'isMultiplayer': false,
                      'showHint': _showHintToImpostor,
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Multiple Devices Card
              _buildModeCard(
                icon: Icons.devices,
                iconColor: AppColors.primario,
                title: "Múltiples Dispositivos",
                subtitle: "Conecta varios teléfonos vía\nBluetooth/WiFi",
                tags: ["Bluetooth", "WiFi"],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/multi_init',
                    arguments: {'showHint': _showHintToImpostor},
                  );
                },
              ),

              const Spacer(),

              // History button
              _buildSecondaryButton(
                icon: Icons.history,
                label: "Historial de Juegos",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Próximamente...")),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Settings button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _showSettingsDialog(context);
                  },
                  icon: Icon(
                    Icons.settings,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  label: Text(
                    "Configuración",
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    List<String>? tags,
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
            border: Border.all(color: AppColors.secondary.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                        height: 1.3,
                      ),
                    ),
                    if (tags != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children:
                            tags
                                .map(
                                  (tag) => Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          tag == "Bluetooth"
                                              ? Icons.bluetooth
                                              : Icons.wifi,
                                          size: 12,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primario, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Configuración",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.fondo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pista para impostor",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.texto,
                                  ),
                                ),
                                Text(
                                  "El impostor ve una pista",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _showHintToImpostor,
                          onChanged: (val) {
                            setModalState(() => _showHintToImpostor = val);
                            setState(() => _showHintToImpostor = val);
                          },
                          activeColor: AppColors.primario,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
