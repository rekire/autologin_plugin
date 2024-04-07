import 'package:freezed_annotation/freezed_annotation.dart';

part 'compatibilities.freezed.dart';

part 'compatibilities.g.dart';

/// The [Compatibilities] report of the current platform or the browser in case
/// of web.
@Freezed(fromJson: true, toJson: true)
class Compatibilities with _$Compatibilities {
  /// Create a new instance of [Compatibilities].
  const factory Compatibilities({
    /// `true` when the current platform is supported. Default value is `false`.
    @Default(false) bool isPlatformSupported,

    /// `true` when secrets can be stored. Default value is `false`.
    @Default(false) bool canSafeSecrets,

    /// `true` when the secrets can be encrypted. Default value is `false`.
    @Default(false) bool canEncryptSecrets,

    /// `true` when zero touch logins is supported. Default value is `false`.
    @Default(false) bool hasZeroTouchSupport,
  }) = _Compatibilities;

  /// Get the [Compatibilities] from a Map.
  static Compatibilities? fromMap(Map<String, Object?>? map) =>
      map == null ? null : _$CompatibilitiesFromJson(map);
}
