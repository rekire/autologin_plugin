import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'compatibilities.freezed.dart';

part 'compatibilities.g.dart';

@Freezed(fromJson: true, toJson: true)
class Compatibilities with _$Compatibilities {
  const factory Compatibilities({
    @Default(false) bool isPlatformSupported,
    @Default(false) bool canSafeSecrets,
    @Default(false) bool canEncryptSecrets,
    @Default(false) bool hasZeroTouchSupport,
  }) = _Compatibilities;

  static Compatibilities? fromJson(String? json) =>
      json == null ? null : _$CompatibilitiesFromJson(jsonDecode(json) as Map<String, Object?>);
}
