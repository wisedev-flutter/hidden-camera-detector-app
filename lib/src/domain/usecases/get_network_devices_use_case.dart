import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';
import '../entities/detected_device.dart';
import '../repositories/device_scan_repository.dart';

class GetNetworkDevicesUseCase {
  const GetNetworkDevicesUseCase(this._repository);

  final DeviceScanRepository _repository;

  Stream<Either<Failure, List<DetectedDevice>>> call() {
    return _repository.watchNetworkDevices();
  }
}
