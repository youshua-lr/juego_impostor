// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameSessionAdapter extends TypeAdapter<GameSession> {
  @override
  final int typeId = 3;

  @override
  GameSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameSession(
      hostId: fields[0] as String,
      players: (fields[1] as List).cast<Player>(),
      impostorCount: fields[2] as int,
      status: fields[3] as GameStatus,
    );
  }

  @override
  void write(BinaryWriter writer, GameSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.hostId)
      ..writeByte(1)
      ..write(obj.players)
      ..writeByte(2)
      ..write(obj.impostorCount)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameStatusAdapter extends TypeAdapter<GameStatus> {
  @override
  final int typeId = 2;

  @override
  GameStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameStatus.setup;
      case 1:
        return GameStatus.playing;
      case 2:
        return GameStatus.finished;
      default:
        return GameStatus.setup;
    }
  }

  @override
  void write(BinaryWriter writer, GameStatus obj) {
    switch (obj) {
      case GameStatus.setup:
        writer.writeByte(0);
        break;
      case GameStatus.playing:
        writer.writeByte(1);
        break;
      case GameStatus.finished:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
