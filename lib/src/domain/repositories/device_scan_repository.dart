import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';
import '../entities/detected_device.dart';

abstract class DeviceScanRepository {
  Future<Either<Failure, List<DetectedDevice>>> getNetworkDevices();
  Future<Either<Failure, List<DetectedDevice>>> getBluetoothDevices();
}
