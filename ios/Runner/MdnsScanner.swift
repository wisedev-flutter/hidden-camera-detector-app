import Foundation
import Network

final class MdnsScanner {
  private let streamApi: HCDScannerStreamApi
  private let queue = DispatchQueue(label: "com.hiddenCameraDetector.mdnsScanner", qos: .userInitiated)
  private var timer: DispatchSourceTimer?
  private var isScanning = false
  private var eventCounter = 0
  private var lastEvent: HCDDeviceEventDto?
  private let permissionValidator = LocalNetworkPermissionValidator()

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

    if let lastEvent = lastEvent, !lastEvent.isFinal.boolValue {
      emitFinalEvent(from: lastEvent)
    }

    completion(nil)
  }

  private func scheduleMockEvents() {
    let devices = MockDeviceFactory.wifiDevices()
    var emissionIndex = 0

    timer = DispatchSource.makeTimerSource(queue: queue)
    timer?.schedule(deadline: .now(), repeating: .milliseconds(800))
    timer?.setEventHandler { [weak self] in
      guard let self = self, self.isScanning else { return }

      if emissionIndex >= devices.count {
        self.isScanning = false
        self.timer?.cancel()
        self.timer = nil
        if let lastEvent = self.lastEvent, !lastEvent.isFinal.boolValue {
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
      with: .wifi,
      device: device,
      eventId: NSNumber(value: eventId),
      totalDiscovered: NSNumber(value: total),
      isFinal: NSNumber(value: isFinal)
    )

    lastEvent = event
    DispatchQueue.main.async { [weak self] in
      self?.streamApi.onDeviceEventEvent(event) { _ in }
    }
  }

  private func emitFinalEvent(from event: HCDDeviceEventDto) {
    let finalEvent = HCDDeviceEventDto.make(
      with: event.source,
      device: event.device,
      eventId: NSNumber(value: nextEventId()),
      totalDiscovered: event.totalDiscovered,
      isFinal: NSNumber(value: true)
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

private struct LocalNetworkPermissionValidator {
  func validate() -> FlutterError? {
    guard #available(iOS 14.0, *) else { return nil }

    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let semaphore = DispatchSemaphore(value: 0)
    var observedStatus: NWPath.Status = .requiresConnection

    monitor.pathUpdateHandler = { path in
      observedStatus = path.status
      semaphore.signal()
    }

    let monitorQueue = DispatchQueue(label: "com.hiddenCameraDetector.localNetworkPermission")
    monitor.start(queue: monitorQueue)
    defer { monitor.cancel() }

    let waitResult = semaphore.wait(timeout: .now() + .milliseconds(200))
    if waitResult == .timedOut {
      return nil
    }

    if observedStatus == .unsatisfied || observedStatus == .requiresConnection {
      return FlutterError(
        code: "PERMISSION_DENIED",
        message: "Local Network access is not available or permission has been denied.",
        details: "NWPathMonitor returned status \(observedStatus)."
      )
    }

    return nil
  }
}

enum MockDeviceFactory {
  static func wifiDevices() -> [HCDDeviceDto] {
    return [
      HCDDeviceDto.make(
        withId: "AA:BB:CC:11:22:33",
        name: "Nest Cam",
        source: .wifi,
        manufacturer: "Google",
        ipAddress: "192.168.1.24",
        rssi: nil,
        isTrusted: NSNumber(value: false),
        riskLevel: HCDPigeonDeviceRiskLevelBox(value: .high)
      ),
      HCDDeviceDto.make(
        withId: "AA:BB:CC:44:55:66",
        name: "Smart Plug",
        source: .wifi,
        manufacturer: "TP-Link",
        ipAddress: "192.168.1.42",
        rssi: nil,
        isTrusted: NSNumber(value: false),
        riskLevel: HCDPigeonDeviceRiskLevelBox(value: .medium)
      ),
      HCDDeviceDto.make(
        withId: "AA:BB:CC:77:88:99",
        name: "Office Printer",
        source: .wifi,
        manufacturer: "HP",
        ipAddress: "192.168.1.65",
        rssi: nil,
        isTrusted: NSNumber(value: true),
        riskLevel: HCDPigeonDeviceRiskLevelBox(value: .low)
      ),
    ]
  }
}
