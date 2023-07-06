//
//  IntentHandler.swift
//  AkiflowIntent
//
//  Created by Emanuel Tesoriello on 17/06/23.
//


import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        print("handler runned")

        guard intent is AkiflowIntent else {
            fatalError("Unhandled Intent error : \(intent)")
        }
        return self
    }
}

class AkiflowHandler: NSObject, AkiflowIntentHandling {
    
    
    func handle(intent: AkiflowIntent, completion: @escaping (AkiflowIntentResponse) -> Void) {
        print("handle runned")
        if let title = intent.title {
            let numberOfCreatedTasks = createTask(title: title)
            completion(AkiflowIntentResponse(code: AkiflowIntentResponseCode.success,userActivity: nil))
           //completion(AkiflowIntentResponse.success(numberOfTasksCreated: NSNumber(value: numberOfCreatedTasks)))
        }
    }
    
    
    func resolveTitle(for intent: AkiflowIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        print("resolveTitle runned")
        guard let title = intent.title else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(INStringResolutionResult.success(with: title))
    }
    
    
    func createTask(title: String) -> Int {
        print("createTask runned")
        var data = [[String:Any]]()
        data.append(["title": title])
        if let userDefaults = UserDefaults(suiteName: "group.com.akiflow.mobile") {
            if let billData = userDefaults.array(forKey: "auth") as? [[String: Any]] {
                data.append(contentsOf: billData)
                userDefaults.setValue(data, forKey: "auth")
            } else {
                userDefaults.setValue(data, forKey: "auth")
            }
        }
        return data.count
    }
}
