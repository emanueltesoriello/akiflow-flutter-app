import UIKit
import Flutter
import workmanager

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GeneratedPluginRegistrant.register(with: self)
        //UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            // Registry in this case is the FlutterEngine that is created in Workmanager's
            // performFetchWithCompletionHandler or BGAppRefreshTask.
            // This will make other plugins available during a background operation.
            GeneratedPluginRegistrant.register(with: registry)
        }

    WorkmanagerPlugin.registerTask(withIdentifier: "com.akiflow.mobile.periodicTask")

    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.akiflow.mobile/firstDayOfWeek", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "getFirstDayOfWeek" {
                let firstDayOfWeek = self?.getFirstDayOfWeek()
                result(firstDayOfWeek)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)

    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert) // shows banner even if app is in foreground
     }

    func getFirstDayOfWeek() -> Int {
        let calendar = Calendar.current
        return calendar.firstWeekday
    }

}