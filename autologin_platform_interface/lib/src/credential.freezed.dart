// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Credential _$CredentialFromJson(Map<String, dynamic> json) {
  return _Credential.fromJson(json);
}

/// @nodoc
mixin _$Credential {
  String? get username => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CredentialCopyWith<Credential> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialCopyWith<$Res> {
  factory $CredentialCopyWith(
          Credential value, $Res Function(Credential) then) =
      _$CredentialCopyWithImpl<$Res, Credential>;
  @useResult
  $Res call({String? username, String? password});
}

/// @nodoc
class _$CredentialCopyWithImpl<$Res, $Val extends Credential>
    implements $CredentialCopyWith<$Res> {
  _$CredentialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = freezed,
    Object? password = freezed,
  }) {
    return _then(_value.copyWith(
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredentialImplCopyWith<$Res>
    implements $CredentialCopyWith<$Res> {
  factory _$$CredentialImplCopyWith(
          _$CredentialImpl value, $Res Function(_$CredentialImpl) then) =
      __$$CredentialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? username, String? password});
}

/// @nodoc
class __$$CredentialImplCopyWithImpl<$Res>
    extends _$CredentialCopyWithImpl<$Res, _$CredentialImpl>
    implements _$$CredentialImplCopyWith<$Res> {
  __$$CredentialImplCopyWithImpl(
      _$CredentialImpl _value, $Res Function(_$CredentialImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = freezed,
    Object? password = freezed,
  }) {
    return _then(_$CredentialImpl(
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialImpl implements _Credential {
  const _$CredentialImpl({this.username, this.password});

  factory _$CredentialImpl.fromJson(Map<String, dynamic> json) =>
      _$$CredentialImplFromJson(json);

  @override
  final String? username;
  @override
  final String? password;

  @override
  String toString() {
    return 'Credential(username: $username, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, username, password);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialImplCopyWith<_$CredentialImpl> get copyWith =>
      __$$CredentialImplCopyWithImpl<_$CredentialImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialImplToJson(
      this,
    );
  }
}

abstract class _Credential implements Credential {
  const factory _Credential({final String? username, final String? password}) =
      _$CredentialImpl;

  factory _Credential.fromJson(Map<String, dynamic> json) =
      _$CredentialImpl.fromJson;

  @override
  String? get username;
  @override
  String? get password;
  @override
  @JsonKey(ignore: true)
  _$$CredentialImplCopyWith<_$CredentialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
