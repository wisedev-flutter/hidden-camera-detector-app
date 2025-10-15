import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';
import '../entities/detected_device.dart';

abstract class DeviceScanRepository {
  Stream<Either<Failure, List<DetectedDevice>>> watchNetworkDevices();
  Stream<Either<Failure, List<DetectedDevice>>> watchBluetoothDevices();
}
