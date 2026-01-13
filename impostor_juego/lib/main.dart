import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/player_model.dart';
import 'models/game_session_model.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'screens/game_setup_screen.dart';
import 'screens/role_reveal_screen.dart';
import 'screens/game_dashboard_screen.dart';
import 'screens/multiplayer_setup_screen.dart';
import 'screens/game_results_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/voting_screen.dart';

// App Color Palette
class AppColors {
  static const Color primario = Color(0xFF2563EB); // Blue vibrante
  static const Color fondo = Color(0xFFF8FAFC); // Blanco suave
  static const Color texto = Color(0xFF1E293B); // Gris azulado oscuro

  // Bootstrap colors
  static const Color success = Color(0xFF198754);
  static const Color danger = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF0DCAF0);
  static const Color secondary = Color(0xFF6C757D);
  static const Color light = Color(0xFFF8F9FA);
  static const Color dark = Color(0xFF212529);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(RoleAdapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(GameStatusAdapter());
  Hive.registerAdapter(GameSessionAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: MaterialApp(
        title: 'Impostor Game',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primario,
            brightness: Brightness.light,
            primary: AppColors.primario,
            surface: AppColors.fondo,
            onSurface: AppColors.texto,
          ),
          scaffoldBackgroundColor: AppColors.fondo,
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primario,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primario,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/setup': (context) => const GameSetupScreen(),
          '/category': (context) => const CategorySelectionScreen(),
          '/reveal': (context) => const RoleRevealScreen(),
          '/game': (context) => const GameDashboardScreen(),
          '/voting': (context) => const VotingScreen(),
          '/results': (context) => const GameResultsScreen(),
          '/multi_init': (context) => const MultiplayerInitScreen(),
          '/multi_host': (context) => const HostLobbyScreen(),
          '/multi_join': (context) => const ClientJoinScreen(),
          '/multi_client_lobby': (context) => const ClientLobbyScreen(),
        },
      ),
    );
  }
}
