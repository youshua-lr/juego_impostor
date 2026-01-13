import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'player_model.g.dart'; // For Hive generation later

@HiveType(typeId: 0)
enum Role {
  @HiveField(0)
  citizen,
  @HiveField(1)
  impostor,
}

@HiveType(typeId: 1)
class Player {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Role role;

  @HiveField(3)
  bool isAlive;

  Player({
    required this.id,
    required this.name,
    this.role = Role.citizen,
    this.isAlive = true,
  });

  factory Player.create({required String name}) {
    return Player(id: const Uuid().v4(), name: name);
  }

  @override
  String toString() => 'Player(id: $id, name: $name, role: $role)';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.index,
    'isAlive': isAlive,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      role: Role.values[json['role']],
      isAlive: json['isAlive'],
    );
  }
}
