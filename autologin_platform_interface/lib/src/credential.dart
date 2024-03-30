import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential.freezed.dart';

part 'credential.g.dart';

/// Container for your [Credential]s. Based on your use case all fields can be `null`.
@Freezed(fromJson: true, toJson: true)
class Credential with _$Credential {
  /// Create a new [Credential], the [username] and [password] are both optional, even if this is not useful and
  /// therefore not recommended to keep both values null. For iOS and MacOS the [domain] is mandatory, on other
  /// platforms this field is not used.
  const factory Credential({
    String? username,
    String? password,
    String? domain,
  }) = _Credential;

  /// Get the [Credential] from a Map.
  static Credential? fromMap(Map<String, Object?>? map) => map == null ? null : _$CredentialFromJson(map);
}
