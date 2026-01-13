import 'package:flutter/material.dart';
import '../main.dart';
import '../services/game_data_service.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool _isLoading = true;
  String? _selectedCategory;

  final Map<String, IconData> _categoryIcons = {
    'super_heroes': Icons.flash_on,
    'peliculas': Icons.movie,
    'futbol': Icons.sports_soccer,
    'anime': Icons.animation,
    'juegos_de_consola': Icons.videogame_asset,
    'paises': Icons.public,
    'maravillas_del_mundo': Icons.account_balance,
  };

  final Map<String, String> _categoryNames = {
    'super_heroes': 'Superhéroes',
    'peliculas': 'Películas',
    'futbol': 'Fútbol',
    'anime': 'Anime',
    'juegos_de_consola': 'Videojuegos',
    'paises': 'Países',
    'maravillas_del_mundo': 'Maravillas del Mundo',
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await GameDataService.loadData();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final showHint = args?['showHint'] ?? false;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.fondo,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primario),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(title: const Text("Elegir Categoría"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "¿Sobre qué tema quieren jugar?",
              style: TextStyle(fontSize: 18, color: AppColors.texto),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: GameDataService.categories.length,
              itemBuilder: (context, index) {
                final categoryKey = GameDataService.categories[index];
                final isSelected = _selectedCategory == categoryKey;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = categoryKey),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primario : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primario
                                : AppColors.secondary.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isSelected
                                  ? AppColors.primario.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 15 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _categoryIcons[categoryKey] ?? Icons.category,
                          size: 40,
                          color: isSelected ? Colors.white : AppColors.primario,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _categoryNames[categoryKey] ?? categoryKey,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.texto,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedCategory != null
                          ? AppColors.primario
                          : AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                    _selectedCategory != null
                        ? () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/reveal',
                            arguments: {
                              'showHint': showHint,
                              'category': _selectedCategory,
                            },
                          );
                        }
                        : null,
                child: const Text(
                  "CONTINUAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
