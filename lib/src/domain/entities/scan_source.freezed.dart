// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ScanSource {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() wifi,
    required TResult Function() bluetooth,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? wifi,
    TResult? Function()? bluetooth,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? wifi,
    TResult Function()? bluetooth,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Wifi value) wifi,
    required TResult Function(_Bluetooth value) bluetooth,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Wifi value)? wifi,
    TResult? Function(_Bluetooth value)? bluetooth,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Wifi value)? wifi,
    TResult Function(_Bluetooth value)? bluetooth,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanSourceCopyWith<$Res> {
  factory $ScanSourceCopyWith(
    ScanSource value,
    $Res Function(ScanSource) then,
  ) = _$ScanSourceCopyWithImpl<$Res, ScanSource>;
}

/// @nodoc
class _$ScanSourceCopyWithImpl<$Res, $Val extends ScanSource>
    implements $ScanSourceCopyWith<$Res> {
  _$ScanSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScanSource
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$WifiImplCopyWith<$Res> {
  factory _$$WifiImplCopyWith(
    _$WifiImpl value,
    $Res Function(_$WifiImpl) then,
  ) = __$$WifiImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WifiImplCopyWithImpl<$Res>
    extends _$ScanSourceCopyWithImpl<$Res, _$WifiImpl>
    implements _$$WifiImplCopyWith<$Res> {
  __$$WifiImplCopyWithImpl(_$WifiImpl _value, $Res Function(_$WifiImpl) _then)
    : super(_value, _then);

  /// Create a copy of ScanSource
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$WifiImpl extends _Wifi {
  const _$WifiImpl() : super._();

  @override
  String toString() {
    return 'ScanSource.wifi()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$WifiImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() wifi,
    required TResult Function() bluetooth,
  }) {
    return wifi();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? wifi,
    TResult? Function()? bluetooth,
  }) {
    return wifi?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? wifi,
    TResult Function()? bluetooth,
    required TResult orElse(),
  }) {
    if (wifi != null) {
      return wifi();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Wifi value) wifi,
    required TResult Function(_Bluetooth value) bluetooth,
  }) {
    return wifi(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Wifi value)? wifi,
    TResult? Function(_Bluetooth value)? bluetooth,
  }) {
    return wifi?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Wifi value)? wifi,
    TResult Function(_Bluetooth value)? bluetooth,
    required TResult orElse(),
  }) {
    if (wifi != null) {
      return wifi(this);
    }
    return orElse();
  }
}

abstract class _Wifi extends ScanSource {
  const factory _Wifi() = _$WifiImpl;
  const _Wifi._() : super._();
}

/// @nodoc
abstract class _$$BluetoothImplCopyWith<$Res> {
  factory _$$BluetoothImplCopyWith(
    _$BluetoothImpl value,
    $Res Function(_$BluetoothImpl) then,
  ) = __$$BluetoothImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BluetoothImplCopyWithImpl<$Res>
    extends _$ScanSourceCopyWithImpl<$Res, _$BluetoothImpl>
    implements _$$BluetoothImplCopyWith<$Res> {
  __$$BluetoothImplCopyWithImpl(
    _$BluetoothImpl _value,
    $Res Function(_$BluetoothImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScanSource
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BluetoothImpl extends _Bluetooth {
  const _$BluetoothImpl() : super._();

  @override
  String toString() {
    return 'ScanSource.bluetooth()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BluetoothImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() wifi,
    required TResult Function() bluetooth,
  }) {
    return bluetooth();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? wifi,
    TResult? Function()? bluetooth,
  }) {
    return bluetooth?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? wifi,
    TResult Function()? bluetooth,
    required TResult orElse(),
  }) {
    if (bluetooth != null) {
      return bluetooth();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Wifi value) wifi,
    required TResult Function(_Bluetooth value) bluetooth,
  }) {
    return bluetooth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Wifi value)? wifi,
    TResult? Function(_Bluetooth value)? bluetooth,
  }) {
    return bluetooth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Wifi value)? wifi,
    TResult Function(_Bluetooth value)? bluetooth,
    required TResult orElse(),
  }) {
    if (bluetooth != null) {
      return bluetooth(this);
    }
    return orElse();
  }
}

abstract class _Bluetooth extends ScanSource {
  const factory _Bluetooth() = _$BluetoothImpl;
  const _Bluetooth._() : super._();
}
