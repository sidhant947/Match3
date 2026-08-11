import 'package:hive/hive.dart';
import 'package:match3/domain/models/user_progress.dart';

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    final rawStars = fields[2];
    final Map<String, int> starsMap;
    if (rawStars is Map) {
      starsMap = Map<String, int>.from(rawStars);
    } else {
      starsMap = const {};
    }

    return UserProgress(
      currentLevel: fields[0] as int? ?? 1,
      highestLevelCompleted: fields[1] as int? ?? 0,
      levelStars: starsMap,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer.writeByte(3);
    writer.writeByte(0);
    writer.write(obj.currentLevel);
    writer.writeByte(1);
    writer.write(obj.highestLevelCompleted);
    writer.writeByte(2);
    writer.write(obj.levelStars);
  }
}
