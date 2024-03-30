import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'compatibilities.freezed.dart';

part 'compatibilities.g.dart';

/// The [Compatibilities] of the current Platform.
@Freezed(fromJson: true, toJson: true)
class Compatibilities with _$Compatibilities {
  const factory Compatibilities({
    @Default(false) bool isPlatformSupported,
    @Default(false) bool canSafeSecrets,
    @Default(false) bool canEncryptSecrets,
    @Default(false) bool hasZeroTouchSupport,
  }) = _Compatibilities;

  /// Get the [Compatibilities] from a Map.
  static Compatibilities? fromMap(Map<String, Object?>? map) => map == null ? null : _$CompatibilitiesFromJson(map);
}
