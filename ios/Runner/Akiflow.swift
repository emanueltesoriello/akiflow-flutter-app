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
            "title": title,
            "date": NSNull(), 
            "description": "",
            "duration": NSNull(),
            "status": 1,
            "created_at": "2023-06-27T17:22:55.055164Z",
            "updated_at": "2023-06-27T17:22:55.055164Z",
            "deleted_at": NSNull(),
            "remote_list_id_updated_at": NSNull(),
            "global_list_id_updated_at": NSNull(),
            "done": false,
            "done_at": NSNull(),
            "datetime": NSNull(),
            "read_at": NSNull(),
            "global_updated_at": "2023-06-27T17:22:55.055164Z",
            "global_created_at": "2023-06-27T17:22:55.055164Z",
            "activation_datetime": NSNull(),
            "due_date": NSNull(),
            "remote_updated_at": NSNull(),
            "recurring_id": NSNull(),
            "priority": NSNull(),
            "listId": NSNull(),
            "section_id": NSNull(),
            "origin": NSNull(),
            "sorting": 1687871996165,
            "sorting_label": NSNull(),
            "trashed_at": NSNull(),
            "selected": NSNull(),
            "dailyGoal": NSNull(),
            "links": NSNull(),
            "recurrence": NSNull(),
            "content": NSNull(),
            "connector_id": NSNull(),
            "origin_id": NSNull(),
            "origin_account_id": NSNull(),
            "akiflow_account_id": NSNull(),
            "calendar_id": NSNull(),
            "doc": NSNull()
        ]
    ]

    // Convert the task object to Data
    guard let taskData = try? JSONSerialization.data(withJSONObject: taskObject, options: []) else {
        // Handle the case when the task object cannot be converted to data
        throw NSError(domain: "com.akiflow.mobile", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert task object to data"])
    }
    
    if let taskDataString = String(data: taskData, encoding: .utf8) {
        print("Task Data: \(taskDataString)")
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
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Set the request body with the task data
    request.httpBody = taskData

    // Create a URLSession task to perform the request
    let (data, response) = try await URLSession.shared.data(for: request)

    if let responseData = String(data: data, encoding: .utf8) {
        print("Response Data: \(responseData)")
    }
    // Check the response status code
    if let httpResponse = response as? HTTPURLResponse {
        print("HTTP Response: \(httpResponse)")
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
                        
                        let myTitle = try await $title.requestValue()
                    
                        try await makeAPICall(withAccessToken: accessToken, title: myTitle)
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
            phrases: ["Create a new task in \(.applicationName).",
                      "Add a task in \(.applicationName).",
                      "Create a new task in \(.applicationName).",
                      "Can you help me make a task in \(.applicationName)?",
                      "Start a new task in \(.applicationName).",
                      "Please create a task in \(.applicationName).",
                      "I need to make a task in \(.applicationName).",
                      "Add a new task in \(.applicationName).",
                      "I want to create a task in \(.applicationName).",
                      "Could you add a new task in \(.applicationName)?",
                      "Let's create a task in \(.applicationName).",
                      "I want to make a task in \(.applicationName).",
                      "Help me add a task in \(.applicationName), please.",
                      "Start a new task in \(.applicationName) for me.",
                      "I need to add a task in \(.applicationName).",
                      "Assist me in creating a task in \(.applicationName).",
                      "Add a new task in my \(.applicationName) app.",
                      "Can you help me with a task in \(.applicationName)?",
                      "Add a new task in \(.applicationName) for me.",
                      "Let's make a task in \(.applicationName) together.",
                      "Create a task in \(.applicationName) now."],
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
