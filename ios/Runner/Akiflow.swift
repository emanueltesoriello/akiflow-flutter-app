import Foundation
import AppIntents


func refreshAccessToken(withRefreshToken refreshToken: String) async throws -> String {
    let refreshTokenURLString = "https://web.akiflow.com/oauth/refreshToken"
    
    // Create the refresh token request
    var refreshTokenRequest = URLRequest(url: URL(string: refreshTokenURLString)!)
    refreshTokenRequest.httpMethod = "POST"
    
    // Set the request body with the refresh token
    let requestBody: [String: Any] = [
        "client_id": "1000006",
        "refresh_token": refreshToken
    ]
    refreshTokenRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    refreshTokenRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Perform the refresh token request
    let (refreshTokenData, refreshTokenResponse) = try await URLSession.shared.data(for: refreshTokenRequest)

    // Check the refresh token response
    if let jsonDict = try JSONSerialization.jsonObject(with: refreshTokenData, options: []) as? [String: Any],
       let accessToken = jsonDict["access_token"] as? String {
        return accessToken
    } else {
        throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh access token"])
    }
}

func makeAPICall(withAccessToken accessToken: String, refreshToken: String, title: String) async throws {
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
            "status": 1,
            "done": false,
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
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            print("invalid AccessToken")
            // Call refresh token API passing refreshToken and receive back the new accessToken
            let newAccessToken = try await refreshAccessToken(withRefreshToken: refreshToken)
            
            // Retry the API call with the new accessToken
            try await makeAPICall(withAccessToken: newAccessToken, refreshToken: refreshToken, title: title)
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
                        // intercept the answer prompt
                        // pass the title to the makeAPICall method
                        if((title != nil) && (!title!.isEmpty) && (title != "My Akiflow task!")){
                            try await makeAPICall(withAccessToken: accessToken, refreshToken: jsonDict["refresh_token"] as! String, title: title!)
                        }
                        else {
                            let myTitle = try await $title.requestValue()
                            
                            try await makeAPICall(withAccessToken: accessToken, refreshToken: jsonDict["refresh_token"] as! String, title: myTitle)
                        }
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
                      "New task with title: \(\.$title)",
                      "New task with title: \(\.$title). In \(.applicationName)",
                      "New task with title: \(\.$title). Using \(.applicationName)",
                      "Create a new task in \(.applicationName) \(\.$title)",
                      "Create a new task with \(.applicationName).",
                      "Add a task in \(.applicationName).",
                      "Add a task \(\.$title) with \(.applicationName).",
                      "Add a task in \(.applicationName) \(\.$title)",
                      "Add a task with title \(\.$title).",
                      "Can you help me make a task in \(.applicationName)?",
                      "Can you help me make a task with \(.applicationName)?",
                      "Start a new task in \(.applicationName).",
                      "Start a new task with \(.applicationName).",
                      "Please create a task in \(.applicationName).",
                      "Please create a task with \(.applicationName).",
                      "I need to make a task in \(.applicationName).",
                      "I need to make a task with \(.applicationName).",
                      "Add a new task in \(.applicationName).",
                      "Add a new task with \(.applicationName).",
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
                      "Create a task in \(.applicationName).",
                      "Create a task with \(.applicationName).",
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
