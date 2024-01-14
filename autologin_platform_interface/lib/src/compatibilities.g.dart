// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compatibilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompatibilitiesImpl _$$CompatibilitiesImplFromJson(
        Map<String, dynamic> json) =>
    _$CompatibilitiesImpl(
      isPlatformSupported: json['isPlatformSupported'] as bool? ?? false,
      canSafeSecrets: json['canSafeSecrets'] as bool? ?? false,
      canEncryptSecrets: json['canEncryptSecrets'] as bool? ?? false,
      hasZeroTouchSupport: json['hasZeroTouchSupport'] as bool? ?? false,
      hasOneClickSupport: json['hasOneClickSupport'] as bool? ?? false,
    );

Map<String, dynamic> _$$CompatibilitiesImplToJson(
        _$CompatibilitiesImpl instance) =>
    <String, dynamic>{
      'isPlatformSupported': instance.isPlatformSupported,
      'canSafeSecrets': instance.canSafeSecrets,
      'canEncryptSecrets': instance.canEncryptSecrets,
      'hasZeroTouchSupport': instance.hasZeroTouchSupport,
      'hasOneClickSupport': instance.hasOneClickSupport,
    };
