import UIKit
import Flutter
import workmanager
import AppIntents
import Foundation
import Intents



@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {
    
    
    struct CreateTask: AppIntent {
        static let title: LocalizedStringResource = "Create new task"
        

        // Example usage
        var auth = UserDefaults.standard.string(forKey: "auth")
            
          
        @MainActor
        func perform() async throws -> some IntentResult & ProvidesDialog {
            print("Auth is: \(String(describing: auth))")

            return .result(dialog: "Okay, what's the title?")
        }
    }
        
    /*struct CreateTaskAppShortcuts: AppShortcutsProvider {
        static var appShortcuts: [AppShortcut] {
            AppShortcut(
                intent: CreateTask(),
                phrases: ["Create new task in \(.applicationName)"],
                systemImageName: "com.akiflow.mobile"
            )
        }
    }*/

  
    
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

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)

    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert) // shows banner even if app is in foreground
     }

}
