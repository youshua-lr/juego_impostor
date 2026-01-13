import 'package:flutter/material.dart';
import '../main.dart';

class GameDashboardScreen extends StatelessWidget {
  const GameDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primario.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primario.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: Icon(Icons.search, size: 80, color: AppColors.primario),
              ),
              const SizedBox(height: 30),
              Text(
                "¡Encuentra al Impostor!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Discutan entre ustedes...\nHagan preguntas sobre la palabra.",
                style: TextStyle(fontSize: 16, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.people, size: 40, color: AppColors.primario),
                    const SizedBox(height: 12),
                    Text(
                      "Cuando estén listos para votar,\nterminen el juego.",
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/voting');
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "TERMINAR JUEGO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
