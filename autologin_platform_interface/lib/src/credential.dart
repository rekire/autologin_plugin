import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential.freezed.dart';

part 'credential.g.dart';

/// Container for your [Credential]s. Based on your use case all fields can be `null`.
@Freezed(fromJson: true, toJson: true)
class Credential with _$Credential {
  /// Create a new [Credential], the [username] and [password] are both optional, even if this is not useful and
  /// therefore not recommended to keep both values null.
  const factory Credential({
    String? username,
    String? password,
  }) = _Credential;

  /// Get the [Credential] from a JSON string (NOT MAP!)
  static Credential? fromJson(String? json) =>
      json == null ? null : _$CredentialFromJson(jsonDecode(json) as Map<String, Object?>);
}
