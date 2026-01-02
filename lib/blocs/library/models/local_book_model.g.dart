// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_book_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalBookModelAdapter extends TypeAdapter<LocalBookModel> {
  @override
  final int typeId = 10;

  @override
  LocalBookModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalBookModel(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      description: fields[3] as String?,
      genres: (fields[4] as List).cast<String>(),
      language: fields[5] as String,
      pages: fields[6] as int,
      price: fields[7] as double,
      minAge: fields[8] as int,
      publisher: fields[9] as String?,
      storySetting: fields[10] as String?,
      pdfUrl: fields[11] as String,
      localPdfPath: fields[12] as String?,
      readingProgress: fields[14] as double,
      currentPage: fields[15] as int,
      totalPages: fields[16] as int,
      purchasedAt: fields[17] as DateTime,
      lastReadAt: fields[18] as DateTime,
      isDownloaded: fields[19] as bool,
      isRead: fields[20] as bool,
      characters: (fields[21] as List).cast<LocalCharacterModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, LocalBookModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.pages)
      ..writeByte(7)
      ..write(obj.price)
      ..writeByte(8)
      ..write(obj.minAge)
      ..writeByte(9)
      ..write(obj.publisher)
      ..writeByte(10)
      ..write(obj.storySetting)
      ..writeByte(11)
      ..write(obj.pdfUrl)
      ..writeByte(12)
      ..write(obj.localPdfPath)
      ..writeByte(14)
      ..write(obj.readingProgress)
      ..writeByte(15)
      ..write(obj.currentPage)
      ..writeByte(16)
      ..write(obj.totalPages)
      ..writeByte(17)
      ..write(obj.purchasedAt)
      ..writeByte(18)
      ..write(obj.lastReadAt)
      ..writeByte(19)
      ..write(obj.isDownloaded)
      ..writeByte(20)
      ..write(obj.isRead)
      ..writeByte(21)
      ..write(obj.characters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalBookModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalCharacterModelAdapter extends TypeAdapter<LocalCharacterModel> {
  @override
  final int typeId = 11;

  @override
  LocalCharacterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalCharacterModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      avatarPath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalCharacterModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.avatarPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCharacterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
