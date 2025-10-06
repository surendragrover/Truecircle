// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrivacySettingsAdapter extends TypeAdapter<PrivacySettings> {
  @override
  final int typeId = 6;

  @override
  PrivacySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivacySettings(
      contactsAccess: fields[0] as bool,
      callLogAccess: fields[1] as bool,
      smsMetadataAccess: fields[2] as bool,
      sentimentAnalysis: fields[3] as bool,
      aiInsights: fields[4] as bool,
      dataExport: fields[5] as bool,
      notificationsEnabled: fields[6] as bool,
      lastUpdated: fields[7] as DateTime?,
      privacyLevel: fields[8] as String,
      granularPermissions: (fields[9] as Map).cast<String, bool>(),
      hasSeenPrivacyIntro: fields[10] as bool,
      language: fields[11] as String,
      allowCommunicationTracking: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PrivacySettings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.contactsAccess)
      ..writeByte(1)
      ..write(obj.callLogAccess)
      ..writeByte(2)
      ..write(obj.smsMetadataAccess)
      ..writeByte(3)
      ..write(obj.sentimentAnalysis)
      ..writeByte(4)
      ..write(obj.aiInsights)
      ..writeByte(5)
      ..write(obj.dataExport)
      ..writeByte(6)
      ..write(obj.notificationsEnabled)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.privacyLevel)
      ..writeByte(9)
      ..write(obj.granularPermissions)
      ..writeByte(10)
      ..write(obj.hasSeenPrivacyIntro)
      ..writeByte(11)
      ..write(obj.language)
      ..writeByte(12)
      ..write(obj.allowCommunicationTracking);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
