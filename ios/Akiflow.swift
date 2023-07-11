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

    static var title: LocalizedStringResource = "Create a new task"
    static var description = IntentDescription(F"Create a new Akiflow task via Siri dialog")

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

    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        return .result()
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

