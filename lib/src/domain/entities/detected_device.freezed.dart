// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detected_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DetectedDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get manufacturer => throw _privateConstructorUsedError;
  DeviceRiskLevel get riskLevel => throw _privateConstructorUsedError;
  ScanSource get source => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  int? get rssi => throw _privateConstructorUsedError;
  bool get isTrusted => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;

  /// Create a copy of DetectedDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectedDeviceCopyWith<DetectedDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectedDeviceCopyWith<$Res> {
  factory $DetectedDeviceCopyWith(
    DetectedDevice value,
    $Res Function(DetectedDevice) then,
  ) = _$DetectedDeviceCopyWithImpl<$Res, DetectedDevice>;
  @useResult
  $Res call({
    String id,
    String name,
    String manufacturer,
    DeviceRiskLevel riskLevel,
    ScanSource source,
    String? ipAddress,
    int? rssi,
    bool isTrusted,
    DateTime? lastSeen,
  });

  $DeviceRiskLevelCopyWith<$Res> get riskLevel;
  $ScanSourceCopyWith<$Res> get source;
}

/// @nodoc
class _$DetectedDeviceCopyWithImpl<$Res, $Val extends DetectedDevice>
    implements $DetectedDeviceCopyWith<$Res> {
  _$DetectedDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectedDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? manufacturer = null,
    Object? riskLevel = null,
    Object? source = null,
    Object? ipAddress = freezed,
    Object? rssi = freezed,
    Object? isTrusted = null,
    Object? lastSeen = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            manufacturer: null == manufacturer
                ? _value.manufacturer
                : manufacturer // ignore: cast_nullable_to_non_nullable
                      as String,
            riskLevel: null == riskLevel
                ? _value.riskLevel
                : riskLevel // ignore: cast_nullable_to_non_nullable
                      as DeviceRiskLevel,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as ScanSource,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            rssi: freezed == rssi
                ? _value.rssi
                : rssi // ignore: cast_nullable_to_non_nullable
                      as int?,
            isTrusted: null == isTrusted
                ? _value.isTrusted
                : isTrusted // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSeen: freezed == lastSeen
                ? _value.lastSeen
                : lastSeen // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of DetectedDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeviceRiskLevelCopyWith<$Res> get riskLevel {
    return $DeviceRiskLevelCopyWith<$Res>(_value.riskLevel, (value) {
      return _then(_value.copyWith(riskLevel: value) as $Val);
    });
  }

  /// Create a copy of DetectedDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScanSourceCopyWith<$Res> get source {
    return $ScanSourceCopyWith<$Res>(_value.source, (value) {
      return _then(_value.copyWith(source: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DetectedDeviceImplCopyWith<$Res>
    implements $DetectedDeviceCopyWith<$Res> {
  factory _$$DetectedDeviceImplCopyWith(
    _$DetectedDeviceImpl value,
    $Res Function(_$DetectedDeviceImpl) then,
  ) = __$$DetectedDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String manufacturer,
    DeviceRiskLevel riskLevel,
    ScanSource source,
    String? ipAddress,
    int? rssi,
    bool isTrusted,
    DateTime? lastSeen,
  });

  @override
  $DeviceRiskLevelCopyWith<$Res> get riskLevel;
  @override
  $ScanSourceCopyWith<$Res> get source;
}

/// @nodoc
class __$$DetectedDeviceImplCopyWithImpl<$Res>
    extends _$DetectedDeviceCopyWithImpl<$Res, _$DetectedDeviceImpl>
    implements _$$DetectedDeviceImplCopyWith<$Res> {
  __$$DetectedDeviceImplCopyWithImpl(
    _$DetectedDeviceImpl _value,
    $Res Function(_$DetectedDeviceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DetectedDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? manufacturer = null,
    Object? riskLevel = null,
    Object? source = null,
    Object? ipAddress = freezed,
    Object? rssi = freezed,
    Object? isTrusted = null,
    Object? lastSeen = freezed,
  }) {
    return _then(
      _$DetectedDeviceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        manufacturer: null == manufacturer
            ? _value.manufacturer
            : manufacturer // ignore: cast_nullable_to_non_nullable
                  as String,
        riskLevel: null == riskLevel
            ? _value.riskLevel
            : riskLevel // ignore: cast_nullable_to_non_nullable
                  as DeviceRiskLevel,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ScanSource,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        rssi: freezed == rssi
            ? _value.rssi
            : rssi // ignore: cast_nullable_to_non_nullable
                  as int?,
        isTrusted: null == isTrusted
            ? _value.isTrusted
            : isTrusted // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSeen: freezed == lastSeen
            ? _value.lastSeen
            : lastSeen // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$DetectedDeviceImpl implements _DetectedDevice {
  const _$DetectedDeviceImpl({
    required this.id,
    required this.name,
    this.manufacturer = 'Unknown Manufacturer',
    required this.riskLevel,
    required this.source,
    this.ipAddress,
    this.rssi,
    this.isTrusted = false,
    this.lastSeen,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String manufacturer;
  @override
  final DeviceRiskLevel riskLevel;
  @override
  final ScanSource source;
  @override
  final String? ipAddress;
  @override
  final int? rssi;
  @override
  @JsonKey()
  final bool isTrusted;
  @override
  final DateTime? lastSeen;

  @override
  String toString() {
    return 'DetectedDevice(id: $id, name: $name, manufacturer: $manufacturer, riskLevel: $riskLevel, source: $source, ipAddress: $ipAddress, rssi: $rssi, isTrusted: $isTrusted, lastSeen: $lastSeen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectedDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.rssi, rssi) || other.rssi == rssi) &&
            (identical(other.isTrusted, isTrusted) ||
                other.isTrusted == isTrusted) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    manufacturer,
    riskLevel,
    source,
    ipAddress,
    rssi,
    isTrusted,
    lastSeen,
  );

  /// Create a copy of DetectedDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectedDeviceImplCopyWith<_$DetectedDeviceImpl> get copyWith =>
      __$$DetectedDeviceImplCopyWithImpl<_$DetectedDeviceImpl>(
        this,
        _$identity,
      );
}

abstract class _DetectedDevice implements DetectedDevice {
  const factory _DetectedDevice({
    required final String id,
    required final String name,
    final String manufacturer,
    required final DeviceRiskLevel riskLevel,
    required final ScanSource source,
    final String? ipAddress,
    final int? rssi,
    final bool isTrusted,
    final DateTime? lastSeen,
  }) = _$DetectedDeviceImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get manufacturer;
  @override
  DeviceRiskLevel get riskLevel;
  @override
  ScanSource get source;
  @override
  String? get ipAddress;
  @override
  int? get rssi;
  @override
  bool get isTrusted;
  @override
  DateTime? get lastSeen;

  /// Create a copy of DetectedDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectedDeviceImplCopyWith<_$DetectedDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
