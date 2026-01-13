import 'package:flutter/foundation.dart';
import '../models/player_model.dart';
import '../models/game_session_model.dart';
import '../services/game_logic_service.dart';
import '../services/network_service.dart';
import 'package:uuid/uuid.dart';

class GameProvider extends ChangeNotifier {
  GameSession? _currentSession;
  final NetworkService _networkService = NetworkService();
  bool isMultiplayer = false;
  String? hostAddress;
  String myPlayerId = "";

  GameSession? get currentSession => _currentSession;
  List<Player> get players => _currentSession?.players ?? [];
  bool get isGameActive => _currentSession?.status == GameStatus.playing;
  bool get isHost => _currentSession?.hostId == myPlayerId;

  GameProvider() {
    _networkService.onDataReceived = _onNetworkData;
  }

  // --- SETUP ---

  void initSession(String hostId) {
    isMultiplayer = false;
    myPlayerId = hostId == "local_host" ? const Uuid().v4() : hostId;
    _currentSession = GameSession(
      hostId: myPlayerId,
      players: [],
      impostorCount: 1,
      status: GameStatus.setup,
    );
    notifyListeners();
  }

  Future<void> startHosting() async {
    isMultiplayer = true;
    myPlayerId = const Uuid().v4(); // Generate my ID
    hostAddress = await _networkService.startHost();

    _currentSession = GameSession(
      hostId: myPlayerId,
      players: [],
      impostorCount: 1,
      status: GameStatus.setup,
    );
    notifyListeners();
  }

  Future<void> joinGame(String ip, String playerName) async {
    isMultiplayer = true;
    myPlayerId = const Uuid().v4();
    try {
      await _networkService.connectToHost(ip);
      // Send JOIN request
      _networkService.sendToHost({
        'type': 'JOIN',
        'player': Player(id: myPlayerId, name: playerName).toJson(),
      });
    } catch (e) {
      debugPrint("Failed to join: $e");
      rethrow;
    }
  }

  // --- ACTIONS ---

  void addPlayer(String name) {
    if (_currentSession == null) return;

    if (isMultiplayer) {
      if (isHost) {
        final p = Player(id: myPlayerId, name: name);
        // Only add if not already in (could happens if called multiple times)
        if (!_currentSession!.players.any((pl) => pl.id == myPlayerId)) {
          _currentSession!.players.add(p);
          _broadcastState();
          notifyListeners();
        }
      }
    } else {
      // Local
      _currentSession!.players.add(Player.create(name: name));
      notifyListeners();
    }
  }

  void removePlayer(String id) {
    if (_currentSession == null) return;
    _currentSession!.players.removeWhere((p) => p.id == id);
    if (isMultiplayer && isHost) _broadcastState();
    notifyListeners();
  }

  void updateImpostorCount(int count) {
    if (_currentSession == null) return;
    if (count > 0 && count < _currentSession!.players.length) {
      _currentSession!.impostorCount = count;
      if (isMultiplayer && isHost) _broadcastState();
      notifyListeners();
    }
  }

  void startGame() {
    if (_currentSession == null) return;
    if (_currentSession!.players.length < 3) return;

    try {
      // Logic only runs on Host (or Local)
      _currentSession!.players = GameLogicService.assignRoles(
        _currentSession!.players,
        _currentSession!.impostorCount,
      );
      _currentSession!.status = GameStatus.playing;

      if (isMultiplayer && isHost) _broadcastState();

      notifyListeners();
    } catch (e) {
      debugPrint("Error starting game: $e");
    }
  }

  void resetGame() {
    if (_currentSession == null) return;
    _currentSession!.status = GameStatus.setup;
    for (var p in _currentSession!.players) {
      p.role = Role.citizen;
      p.isAlive = true;
    }
    if (isMultiplayer && isHost) _broadcastState();
    notifyListeners();
  }

  // --- NETWORK HANDLING ---

  void _broadcastState() {
    if (_currentSession != null) {
      _networkService.broadcast({
        'type': 'STATE',
        'session': _currentSession!.toJson(),
      });
    }
  }

  void _onNetworkData(Map<String, dynamic> data) {
    final type = data['type'];

    if (isHost) {
      if (type == 'JOIN') {
        final playerJson = data['player'];
        final player = Player.fromJson(playerJson);
        // Add if not exists
        if (!_currentSession!.players.any((p) => p.id == player.id)) {
          _currentSession!.players.add(player);
          _broadcastState();
          notifyListeners();
        }
      }
    } else {
      // Client
      if (type == 'STATE') {
        final sessionJson = data['session'];
        _currentSession = GameSession.fromJson(sessionJson);
        notifyListeners();
      }
    }
  }
}
