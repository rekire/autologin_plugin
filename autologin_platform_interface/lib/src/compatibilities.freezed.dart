// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compatibilities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Compatibilities _$CompatibilitiesFromJson(Map<String, dynamic> json) {
  return _Compatibilities.fromJson(json);
}

/// @nodoc
mixin _$Compatibilities {
  /// `true` when the current platform is supported. Default value is `false`.
  bool get isPlatformSupported => throw _privateConstructorUsedError;

  /// `true` when secrets can be stored. Default value is `false`.
  bool get canSafeSecrets => throw _privateConstructorUsedError;

  /// `true` when the secrets can be encrypted. Default value is `false`.
  bool get canEncryptSecrets => throw _privateConstructorUsedError;

  /// `true` when zero touch logins is supported. Default value is `false`.
  bool get hasZeroTouchSupport => throw _privateConstructorUsedError;

  /// Serializes this Compatibilities to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Compatibilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(ignore: true)
  $CompatibilitiesCopyWith<Compatibilities> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompatibilitiesCopyWith<$Res> {
  factory $CompatibilitiesCopyWith(
          Compatibilities value, $Res Function(Compatibilities) then) =
      _$CompatibilitiesCopyWithImpl<$Res, Compatibilities>;

  @useResult
  $Res call(
      {bool isPlatformSupported,
      bool canSafeSecrets,
      bool canEncryptSecrets,
      bool hasZeroTouchSupport});
}

/// @nodoc
class _$CompatibilitiesCopyWithImpl<$Res, $Val extends Compatibilities>
    implements $CompatibilitiesCopyWith<$Res> {
  _$CompatibilitiesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlatformSupported = null,
    Object? canSafeSecrets = null,
    Object? canEncryptSecrets = null,
    Object? hasZeroTouchSupport = null,
  }) {
    return _then(_value.copyWith(
      isPlatformSupported: null == isPlatformSupported
          ? _value.isPlatformSupported
          : isPlatformSupported // ignore: cast_nullable_to_non_nullable
              as bool,
      canSafeSecrets: null == canSafeSecrets
          ? _value.canSafeSecrets
          : canSafeSecrets // ignore: cast_nullable_to_non_nullable
              as bool,
      canEncryptSecrets: null == canEncryptSecrets
          ? _value.canEncryptSecrets
          : canEncryptSecrets // ignore: cast_nullable_to_non_nullable
              as bool,
      hasZeroTouchSupport: null == hasZeroTouchSupport
          ? _value.hasZeroTouchSupport
          : hasZeroTouchSupport // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompatibilitiesImplCopyWith<$Res>
    implements $CompatibilitiesCopyWith<$Res> {
  factory _$$CompatibilitiesImplCopyWith(_$CompatibilitiesImpl value,
          $Res Function(_$CompatibilitiesImpl) then) =
      __$$CompatibilitiesImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call(
      {bool isPlatformSupported,
      bool canSafeSecrets,
      bool canEncryptSecrets,
      bool hasZeroTouchSupport});
}

/// @nodoc
class __$$CompatibilitiesImplCopyWithImpl<$Res>
    extends _$CompatibilitiesCopyWithImpl<$Res, _$CompatibilitiesImpl>
    implements _$$CompatibilitiesImplCopyWith<$Res> {
  __$$CompatibilitiesImplCopyWithImpl(
      _$CompatibilitiesImpl _value, $Res Function(_$CompatibilitiesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlatformSupported = null,
    Object? canSafeSecrets = null,
    Object? canEncryptSecrets = null,
    Object? hasZeroTouchSupport = null,
  }) {
    return _then(_$CompatibilitiesImpl(
      isPlatformSupported: null == isPlatformSupported
          ? _value.isPlatformSupported
          : isPlatformSupported // ignore: cast_nullable_to_non_nullable
              as bool,
      canSafeSecrets: null == canSafeSecrets
          ? _value.canSafeSecrets
          : canSafeSecrets // ignore: cast_nullable_to_non_nullable
              as bool,
      canEncryptSecrets: null == canEncryptSecrets
          ? _value.canEncryptSecrets
          : canEncryptSecrets // ignore: cast_nullable_to_non_nullable
              as bool,
      hasZeroTouchSupport: null == hasZeroTouchSupport
          ? _value.hasZeroTouchSupport
          : hasZeroTouchSupport // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompatibilitiesImpl implements _Compatibilities {
  const _$CompatibilitiesImpl(
      {this.isPlatformSupported = false,
      this.canSafeSecrets = false,
      this.canEncryptSecrets = false,
      this.hasZeroTouchSupport = false});

  factory _$CompatibilitiesImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompatibilitiesImplFromJson(json);

  /// `true` when the current platform is supported. Default value is `false`.
  @override
  @JsonKey()
  final bool isPlatformSupported;

  /// `true` when secrets can be stored. Default value is `false`.
  @override
  @JsonKey()
  final bool canSafeSecrets;

  /// `true` when the secrets can be encrypted. Default value is `false`.
  @override
  @JsonKey()
  final bool canEncryptSecrets;

  /// `true` when zero touch logins is supported. Default value is `false`.
  @override
  @JsonKey()
  final bool hasZeroTouchSupport;

  @override
  String toString() {
    return 'Compatibilities(isPlatformSupported: $isPlatformSupported, canSafeSecrets: $canSafeSecrets, canEncryptSecrets: $canEncryptSecrets, hasZeroTouchSupport: $hasZeroTouchSupport)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompatibilitiesImpl &&
            (identical(other.isPlatformSupported, isPlatformSupported) ||
                other.isPlatformSupported == isPlatformSupported) &&
            (identical(other.canSafeSecrets, canSafeSecrets) ||
                other.canSafeSecrets == canSafeSecrets) &&
            (identical(other.canEncryptSecrets, canEncryptSecrets) ||
                other.canEncryptSecrets == canEncryptSecrets) &&
            (identical(other.hasZeroTouchSupport, hasZeroTouchSupport) ||
                other.hasZeroTouchSupport == hasZeroTouchSupport));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, isPlatformSupported,
      canSafeSecrets, canEncryptSecrets, hasZeroTouchSupport);

  /// Create a copy of Compatibilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompatibilitiesImplCopyWith<_$CompatibilitiesImpl> get copyWith =>
      __$$CompatibilitiesImplCopyWithImpl<_$CompatibilitiesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompatibilitiesImplToJson(
      this,
    );
  }
}

abstract class _Compatibilities implements Compatibilities {
  const factory _Compatibilities(
      {final bool isPlatformSupported,
      final bool canSafeSecrets,
      final bool canEncryptSecrets,
      final bool hasZeroTouchSupport}) = _$CompatibilitiesImpl;

  factory _Compatibilities.fromJson(Map<String, dynamic> json) =
      _$CompatibilitiesImpl.fromJson;

  /// `true` when the current platform is supported. Default value is `false`.
  @override
  bool get isPlatformSupported;

  /// `true` when secrets can be stored. Default value is `false`.
  @override
  bool get canSafeSecrets;

  /// `true` when the secrets can be encrypted. Default value is `false`.
  @override
  bool get canEncryptSecrets;

  /// `true` when zero touch logins is supported. Default value is `false`.
  @override
  bool get hasZeroTouchSupport;

  /// Create a copy of Compatibilities
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(ignore: true)
  _$$CompatibilitiesImplCopyWith<_$CompatibilitiesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
