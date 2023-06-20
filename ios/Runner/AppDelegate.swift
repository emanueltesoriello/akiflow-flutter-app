import UIKit
import Flutter
import workmanager
import AppIntents
import Foundation
import Intents

fileprivate extension IntentDialog {
    static func titleParameterPrompt(title: String) -> Self {
        "What's the \(title)?"
    }
    static var responseSuccess: Self {
        "Task created! "
    }
    static var responseFailure: Self {
        "Oops! Loos like something went wrong! "
    }
}

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate {

  /*
//@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct Akiflow: AppIntent, PredictableIntent {

    static var title: LocalizedStringResource = "Create a new task"
    static var description = IntentDescription("Create a new Akiflow task via Siri dialog")

    @Parameter(title: "Title")
    var title: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Create a task with title: \(\.$title)")
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$title)) { title in
            DisplayRepresentation(
                title: "Create a task with title: \(title!)",
                subtitle: ""
            )
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("Ciaone intent gone")

        return .result(dialog: "Okay!")
    }
}

struct CreateTaskAppShortcuts: AppShortcutsProvider {
        static var appShortcuts: [AppShortcut] {
            AppShortcut( 
                intent: Akiflow(),
                phrases: ["Create new task in \(.applicationName)"],
                systemImageName: "com.akiflow.mobile"
            )
        }
    }*/


    /*struct CreateTask: AppIntent {
        static let title: LocalizedStringResource = "Create new task"
        

        // Example usage
        var auth = UserDefaults.standard.string(forKey: "auth")
            
          
        @MainActor
        func perform() async throws -> some IntentResult & ProvidesDialog {
            print("Auth is: \(String(describing: auth))")

            return .result(dialog: "Okay, what's the title?")
        }
    }
        
    struct CreateTaskAppShortcuts: AppShortcutsProvider {
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
    
    INInteraction(intent: AkiflowIntent(), response: nil).donate { (error) in
        if let error = error { 
            print("Failed to donate intent: \(error.localizedDescription)")
        } else {
            print("Intent donated successfully")
        }
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

