import Foundation
import AppIntents

func makeAPICall(withAccessToken accessToken: String, title: String) async throws {
    // Define the API endpoint URL
    let urlString = "https://api.akiflow.com/v3/tasks"
    
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime]

    let currentDate = Date()
    let createdAtString = dateFormatter.string(from: currentDate)

    // Create the task object
    let taskObject: [[String: Any]] = [
        [
            "id": UUID().uuidString,
            "status": 1,
            "title": title,
            "created_at": createdAtString,
            "global_created_at": createdAtString
        ]
    ]

    // Convert the task object to Data
    guard let taskData = try? JSONSerialization.data(withJSONObject: taskObject, options: []) else {
        // Handle the case when the task object cannot be converted to data
        throw NSError(domain: "com.akiflow.mobile", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert task object to data"])
    }

    // Create the URL object
    guard let url = URL(string: urlString) else {
        // Handle the case when the URL is invalid
        throw NSError(domain: "com.akiflow.mobile", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }

    // Create the request object
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Set the authorization header with the access token
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    // Set the request body with the task data
    request.httpBody = taskData

    // Create a URLSession task to perform the request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Check the response status code
    if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
            print("API request successful - 200 OK")
            // Handle the successful response here
        } else {
            print("API request failed - Status Code: \(httpResponse.statusCode)")
            throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "API request failed with status code \(httpResponse.statusCode)"])
        }
    }
}

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

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let user = UserDefaults.standard.string(forKey: "flutter.user")
        print(user ?? "Empty user")

        // Convert the JSON string into Data
        if let jsonData = user?.data(using: .utf8) {
            // Convert the JSON data into a Dictionary
            if let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // Access the 'access_token' key from the Dictionary
                if let accessToken = jsonDict["access_token"] as? String {
                    // Use the extracted access_token
                    print("Access Token: \(accessToken)")
                    do {
                        
                        // TODO ask to the user via Siri "What's the title?"
                        // intercept the answer
                        // pass the title to the makeAPICall method
                        
                        try await makeAPICall(withAccessToken: accessToken, title: "Test Emanuel")
                        return .result(dialog: IntentDialog.responseSuccess)
                    } catch {
                        print("API request failed: \(error.localizedDescription)")
                        return .result(dialog: IntentDialog.responseFailure)
                    }
                }
            }
        }

        return .result(dialog: IntentDialog.responseFailure)
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
        "Task created!"
    }
    static var responseFailure: Self {
        "Oops! Looks like something went wrong!"
    }
}
