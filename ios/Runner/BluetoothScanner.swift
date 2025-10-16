import CoreBluetooth
import Foundation

final class BluetoothScanner {
  private let streamApi: HCDScannerStreamApi
  private let queue = DispatchQueue(label: "com.hiddenCameraDetector.bluetoothScanner", qos: .userInitiated)
  private var timer: DispatchSourceTimer?
  private var isScanning = false
  private var eventCounter = 0
  private var lastEvent: HCDDeviceEventDto?
  private let permissionValidator = BluetoothPermissionValidator()

  init(streamApi: HCDScannerStreamApi) {
    self.streamApi = streamApi
  }

  func start(completion: @escaping (FlutterError?) -> Void) {
    guard !isScanning else {
      completion(nil)
      return
    }

    if let permissionError = permissionValidator.validate() {
      completion(permissionError)
      return
    }

    isScanning = true
    eventCounter = 0
    scheduleMockEvents()
    completion(nil)
  }

  func stop(completion: @escaping (FlutterError?) -> Void) {
    guard isScanning else {
      completion(nil)
      return
    }

    isScanning = false
    timer?.cancel()
    timer = nil

    if let lastEvent = lastEvent, !lastEvent.isFinal {
      emitFinalEvent(from: lastEvent)
    }

    completion(nil)
  }

  private func scheduleMockEvents() {
    let devices = MockDeviceFactory.bluetoothDevices()
    var emissionIndex = 0

    timer = DispatchSource.makeTimerSource(queue: queue)
    timer?.schedule(deadline: .now(), repeating: .milliseconds(900))
    timer?.setEventHandler { [weak self] in
      guard let self = self, self.isScanning else { return }

      if emissionIndex >= devices.count {
        self.isScanning = false
        self.timer?.cancel()
        self.timer = nil
        if let lastEvent = self.lastEvent, !lastEvent.isFinal {
          self.emitFinalEvent(from: lastEvent)
        }
        return
      }

      let device = devices[emissionIndex]
      emissionIndex += 1
      self.publish(device: device, total: emissionIndex, isFinal: emissionIndex == devices.count)
    }
    timer?.resume()
  }

  private func publish(device: HCDDeviceDto, total: Int, isFinal: Bool) {
    let eventId = nextEventId()
    let event = HCDDeviceEventDto.make(
      withSource: .bluetooth,
      device: device,
      eventId: eventId,
      totalDiscovered: NSNumber(value: total),
      isFinal: isFinal
    )
    lastEvent = event

    DispatchQueue.main.async { [weak self] in
      self?.streamApi.onDeviceEventEvent(event) { _ in }
    }
  }

  private func emitFinalEvent(from event: HCDDeviceEventDto) {
    let finalEvent = HCDDeviceEventDto.make(
      withSource: event.source,
      device: event.device,
      eventId: nextEventId(),
      totalDiscovered: event.totalDiscovered,
      isFinal: true
    )
    DispatchQueue.main.async { [weak self] in
      self?.streamApi.onDeviceEventEvent(finalEvent) { _ in }
    }
  }

  private func nextEventId() -> Int {
    eventCounter += 1
    return eventCounter
  }
}

private struct BluetoothPermissionValidator {
  func validate() -> FlutterError? {
    if #available(iOS 13.0, *) {
      let status = CBCentralManager.authorization
      switch status {
      case .allowedAlways:
        return nil
      case .denied, .restricted:
        return FlutterError(
          code: "PERMISSION_DENIED",
          message: "Bluetooth access is not authorized.",
          details: "CBCentralManager reported status \(status.rawValue)."
        )
      case .notDetermined:
        return FlutterError(
          code: "PERMISSION_NOT_DETERMINED",
          message: "Bluetooth permission has not been requested yet.",
          details: nil
        )
      @unknown default:
        return FlutterError(
          code: "PERMISSION_UNKNOWN",
          message: "Bluetooth authorization returned an unknown state.",
          details: nil
        )
      }
    } else {
      let legacyStatus = CBPeripheralManager.authorizationStatus()
      switch legacyStatus {
      case .authorized:
        return nil
      case .denied, .restricted:
        return FlutterError(
          code: "PERMISSION_DENIED",
          message: "Bluetooth access is not authorized.",
          details: "CBPeripheralManager authorizationStatus = \(legacyStatus.rawValue)."
        )
      case .notDetermined:
        return FlutterError(
          code: "PERMISSION_NOT_DETERMINED",
          message: "Bluetooth permission has not been requested yet.",
          details: nil
        )
      @unknown default:
        return FlutterError(
          code: "PERMISSION_UNKNOWN",
          message: "Bluetooth authorization returned an unknown state.",
          details: nil
        )
      }
    }
    return nil
  }
}

extension MockDeviceFactory {
  static func bluetoothDevices() -> [HCDDeviceDto] {
    return [
      HCDDeviceDto.make(
        withId: "11:22:33:44:55:66",
        name: "Mini Spy Cam",
        source: .bluetooth,
        manufacturer: "Acme Surveillance",
        ipAddress: nil,
        rssi: NSNumber(value: -45),
        isTrusted: false,
        riskLevel: HCDDeviceRiskLevelDtoBox(value: .high)
      ),
      HCDDeviceDto.make(
        withId: "77:88:99:AA:BB:CC",
        name: "Bluetooth Speaker",
        source: .bluetooth,
        manufacturer: "Sonos",
        ipAddress: nil,
        rssi: NSNumber(value: -62),
        isTrusted: true,
        riskLevel: HCDDeviceRiskLevelDtoBox(value: .medium)
      ),
    ]
  }
}
