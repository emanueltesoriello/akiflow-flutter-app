//
//  Akiflow.swift
//  
//
//  Created by Emanuel Tesoriello on 19/06/23.
//
 
import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct Akiflow: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "AkiflowIntent"

    static var title: LocalizedStringResource = "Create an Akiflow task"
    static var description = IntentDescription("Create a new task via Siri dialog")

    @Parameter(title: "Title", default: "My Akiflow task!")
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

    /*func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        return .result()
    }*/
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let user = UserDefaults.standard.string(forKey: "flutter.user")
        print(user ?? "Empty user")
        
        // Convert the JSON string into Data
        if (user != nil) {
             let jsonData = user?.data(using: .utf8)

            // Convert the JSON data into a Dictionary
            let jsonDict = try? JSONSerialization.jsonObject(with: jsonData! , options: []) as? [String: Any]

            // Access the 'code' key from the Dictionary
            if let code = jsonDict!["code"] as? String {
                // Use the extracted code
                print("Code: \(code)")
            } else {
                // Handle the case when the 'code' key is not present or is not of type String
                print("error");
            }
        }
       
        
        /*if (title != nil)
            {
            IntentParameter(title: Akiflow.title, requestDisambiguationDialog: IntentDialog("What session would you like?"))

                print("Empty")
                return .result(dialog: IntentDialog.responseFailure)
                
            }
        else
            {
                return .result(dialog: IntentDialog.responseSuccess)
                
            }*/
        return .result(dialog: IntentDialog.responseSuccess)
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
}

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

