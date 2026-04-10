import UIKit
import Flutter

let project = FlutterProjectConfiguration(
  assetsPath: Bundle.main.path(forResource: "flutter_assets", ofType: nil)!,
  dartMain: nil,
  dartVmArgs: nil,
  flutterAssetsName: nil,
  settings: nil
)

UIApplicationMain(
  CommandLine.argc,
  CommandLine.unsafeArgv,
  nil,
  NSStringFromClass(AppDelegate.self)
)
