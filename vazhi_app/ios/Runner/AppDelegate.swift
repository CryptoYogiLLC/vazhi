import Flutter
import UIKit
import Darwin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.cryptoyogillc.vazhi/device_info",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
      if call.method == "getMemoryInfo" {
        let totalRam = ProcessInfo.processInfo.physicalMemory / (1024 * 1024)
        let availableRam = os_proc_available_memory() / (1024 * 1024)

        let info: [String: Any] = [
          "totalRam": Int(totalRam),
          "availableRam": Int(availableRam),
          "lowMemory": false,
          "threshold": 0,
        ]
        result(info)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
