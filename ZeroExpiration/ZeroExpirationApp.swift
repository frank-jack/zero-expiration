//
//  ZeroExpirationApp.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/22/22.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@main
struct ZeroExpirationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var modelData = ModelData()
    @ObservedObject var sessionManager = SessionManager()
    init() {
        configureAmplify()
        sessionManager.getCurrentAuthUser()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
    }
}

private func configureAmplify() {
    do {
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.configure()
        print("Amplify configured successfully")
        
    } catch {
        print("could not initialize Amplify", error)
    }
}
