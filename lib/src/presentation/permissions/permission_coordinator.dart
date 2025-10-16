import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../../core/config/app_config.dart';
import '../../pigeon/scanner_api.g.dart';

enum PermissionOutcome {
  granted,
  denied,
  permanentlyDenied,
}

typedef PermissionStatusRequester = Future<ph.PermissionStatus> Function();

class PermissionCoordinator {
  const PermissionCoordinator({
    ScannerHostApi? hostApi,
    PermissionStatusRequester? localNetworkRequester,
    List<PermissionStatusRequester>? bluetoothRequesters,
    Future<bool> Function()? openSettingsCallback,
  })  : _hostApi = hostApi,
        _localNetworkRequester = localNetworkRequester,
        _bluetoothRequesters = bluetoothRequesters,
        _openSettingsCallback = openSettingsCallback;

  final ScannerHostApi? _hostApi;
  final PermissionStatusRequester? _localNetworkRequester;
  final List<PermissionStatusRequester>? _bluetoothRequesters;
  final Future<bool> Function()? _openSettingsCallback;

  ScannerHostApi get _host => _hostApi ?? ScannerHostApi();

  Future<PermissionOutcome> requestLocalNetwork() async {
    if (AppConfig.instance.isMock) {
      return PermissionOutcome.granted;
    }
    try {
      final requester = _localNetworkRequester;
      if (requester != null) {
        final status = await requester();
        return _mapStatus(status);
      }

      final status = await _host.requestLocalNetworkAuthorization();
      return _mapPermissionStatus(status);
    } on PlatformException catch (error) {
      return _mapPlatformException(error);
    }
  }

  Future<PermissionOutcome> requestBluetooth() async {
    if (AppConfig.instance.isMock) {
      return PermissionOutcome.granted;
    }
    final requesters = _bluetoothRequesters ??
        [
          () => ph.Permission.bluetooth.request(),
          () => ph.Permission.bluetoothScan.request(),
          () => ph.Permission.bluetoothConnect.request(),
        ];

    final statuses = <ph.PermissionStatus>[];
    for (final requester in requesters) {
      statuses.add(await requester());
    }
    return _mapCombinedStatuses(statuses);
  }

  Future<bool> openSettings() {
    return _openSettingsCallback?.call() ?? ph.openAppSettings();
  }

  PermissionOutcome _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return PermissionOutcome.granted;
    }
    if (status.isPermanentlyDenied) {
      return PermissionOutcome.permanentlyDenied;
    }
    return PermissionOutcome.denied;
  }

  PermissionOutcome _mapCombinedStatuses(List<ph.PermissionStatus> statuses) {
    if (statuses.any((status) => status.isPermanentlyDenied)) {
      return PermissionOutcome.permanentlyDenied;
    }
    if (statuses.every((status) => status.isGranted || status.isLimited)) {
      return PermissionOutcome.granted;
    }
    return PermissionOutcome.denied;
  }

  PermissionOutcome _mapPermissionStatus(PermissionStatusDto status) {
    switch (status) {
      case PermissionStatusDto.granted:
        return PermissionOutcome.granted;
      case PermissionStatusDto.denied:
        return PermissionOutcome.denied;
      case PermissionStatusDto.permanentlyDenied:
        return PermissionOutcome.permanentlyDenied;
    }
  }

  PermissionOutcome _mapPlatformException(PlatformException exception) {
    switch (exception.code) {
      case 'PERMISSION_DENIED':
      case 'PERMISSION_NOT_DETERMINED':
        return PermissionOutcome.permanentlyDenied;
      default:
        return PermissionOutcome.denied;
    }
  }
}
