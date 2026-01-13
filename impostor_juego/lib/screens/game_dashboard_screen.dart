import 'package:flutter/material.dart';
import '../main.dart';

class GameDashboardScreen extends StatelessWidget {
  const GameDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                "Juego en Curso",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "¡Encuentra al impostor!",
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
              ),

              const Spacer(),

              // Main card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primario.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search,
                        size: 50,
                        color: AppColors.primario,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Discutan entre ustedes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Hagan preguntas sobre la palabra\npara descubrir quién no la conoce",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Cuando estén listos, inicien la votación para descubrir al impostor.",
                        style: TextStyle(fontSize: 13, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Finish button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/voting');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.how_to_vote,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Iniciar Votación",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
