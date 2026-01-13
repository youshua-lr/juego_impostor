import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _showHintToImpostor = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.fondo, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated Logo/Title
              ScaleTransition(
                scale: _pulseAnimation,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primario.withOpacity(0.1),
                        border: Border.all(color: AppColors.primario, width: 3),
                      ),
                      child: Icon(
                        Icons.person_off_rounded,
                        size: 80,
                        color: AppColors.primario,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "IMPOSTOR",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "¿Quién es el traidor?",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Settings Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
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
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Pista para impostor",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.texto,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _showHintToImpostor,
                          onChanged:
                              (val) =>
                                  setState(() => _showHintToImpostor = val),
                          activeColor: AppColors.primario,
                        ),
                      ],
                    ),
                    if (_showHintToImpostor)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "El impostor verá una pista sobre la palabra.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildButton(
                      icon: Icons.phone_android,
                      label: "Un Solo Dispositivo",
                      color: AppColors.primario,
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
                    _buildButton(
                      icon: Icons.wifi,
                      label: "Multijugador WiFi",
                      color: AppColors.success,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/multi_init',
                          arguments: {'showHint': _showHintToImpostor},
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Footer
              Text(
                "v1.0.0",
                style: TextStyle(color: AppColors.secondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
