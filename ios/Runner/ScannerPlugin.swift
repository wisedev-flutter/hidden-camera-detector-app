import Flutter
import Foundation

final class ScannerPlugin: NSObject, HCDScannerHostApi {
  private let streamApi: HCDScannerStreamApi
  private let mdnsScanner: MdnsScanner
  private let bluetoothScanner: BluetoothScanner

  init(binaryMessenger: FlutterBinaryMessenger) {
    streamApi = HCDScannerStreamApi(binaryMessenger: binaryMessenger)
    mdnsScanner = MdnsScanner(streamApi: streamApi)
    bluetoothScanner = BluetoothScanner(streamApi: streamApi)
    super.init()
  }

  func startWifiScan(completion: @escaping (FlutterError?) -> Void) {
    mdnsScanner.start(completion: completion)
  }

  func stopWifiScan(completion: @escaping (FlutterError?) -> Void) {
    mdnsScanner.stop(completion: completion)
  }

  func startBluetoothScan(completion: @escaping (FlutterError?) -> Void) {
    bluetoothScanner.start(completion: completion)
  }

  func stopBluetoothScan(completion: @escaping (FlutterError?) -> Void) {
    bluetoothScanner.stop(completion: completion)
  }
}
