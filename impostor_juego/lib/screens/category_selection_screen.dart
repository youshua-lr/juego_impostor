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
    'peliculas': Icons.movie_outlined,
    'futbol': Icons.sports_soccer,
    'anime': Icons.animation,
    'juegos_de_consola': Icons.videogame_asset_outlined,
    'paises': Icons.public,
    'maravillas_del_mundo': Icons.account_balance_outlined,
  };

  final Map<String, String> _categoryNames = {
    'super_heroes': 'Superhéroes',
    'peliculas': 'Películas',
    'futbol': 'Fútbol',
    'anime': 'Anime',
    'juegos_de_consola': 'Videojuegos',
    'paises': 'Países',
    'maravillas_del_mundo': 'Maravillas',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
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
                        "Elegir Categoría",
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
              Text(
                "¿Sobre qué tema quieren jugar?",
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
              ),

              const SizedBox(height: 30),

              // Categories grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: GameDataService.categories.length,
                  itemBuilder: (context, index) {
                    final categoryKey = GameDataService.categories[index];
                    final isSelected = _selectedCategory == categoryKey;

                    return GestureDetector(
                      onTap:
                          () => setState(() => _selectedCategory = categoryKey),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primario : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primario
                                    : AppColors.secondary.withOpacity(0.15),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _categoryIcons[categoryKey] ?? Icons.category,
                              size: 32,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppColors.primario,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _categoryNames[categoryKey] ?? categoryKey,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : AppColors.texto,
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

              const SizedBox(height: 20),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedCategory != null
                            ? AppColors.primario
                            : AppColors.secondary.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
                  child: Text(
                    _selectedCategory != null
                        ? "Continuar"
                        : "Selecciona una categoría",
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
      ),
    );
  }
}
