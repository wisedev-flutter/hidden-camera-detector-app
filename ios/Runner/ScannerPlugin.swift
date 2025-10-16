import Flutter
import Foundation

final class ScannerPlugin: NSObject, HCDScannerHostApi {
  private let streamApi: HCDScannerStreamApi
  private lazy var mdnsScanner = MdnsScanner(streamApi: streamApi)
  private lazy var bluetoothScanner = BluetoothScanner(streamApi: streamApi)

  init(binaryMessenger: FlutterBinaryMessenger) {
    streamApi = HCDScannerStreamApi(binaryMessenger: binaryMessenger)
    super.init()
  }

  func requestLocalNetworkAuthorization(completion: @escaping (HCDPermissionStatusDtoBox?, FlutterError?) -> Void) {
    mdnsScanner.start { [weak self] error in
      guard let self else { return }
      if let error = error {
        let status: HCDPermissionStatusDto = {
          switch error.code {
          case "PERMISSION_DENIED":
            return .permanentlyDenied
          case "PERMISSION_NOT_DETERMINED":
            return .denied
          default:
            return .denied
          }
        }()
        completion(HCDPermissionStatusDtoBox(value: status), nil)
        return
      }

      self.mdnsScanner.stop { _ in }
      completion(HCDPermissionStatusDtoBox(value: .granted), nil)
    }
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
