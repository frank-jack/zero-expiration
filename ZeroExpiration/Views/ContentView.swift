//
//  ContentView.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/22/22.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

struct ContentView: View {
    @State private var selection: Tab = .input
    @EnvironmentObject var modelData: ModelData
    @ObservedObject var sessionManager = SessionManager()
    @Environment(\.colorScheme) var colorScheme
    let dateFormatter = DateFormatter()
    init() {
        configureAmplify()
        sessionManager.getCurrentAuthUser()
        UITabBar.appearance().backgroundColor = .clear
    }
    enum Tab {
        case input
        case expirables
    }
    @State private var sortType = "expDate"
    @State private var warningDays = 7
    @State private var email = ""
    @State private var notifications = true
    @State private var categories = ["Allergy", "Bug Spray", "Ear Care", "Eye Care", "Pain Medicine", "Sunscreen"]
    @State private var storage: [Expirable] = []
    @State private var temp: [[String]] = [[]]
    var body: some View {
        if modelData.showApp {
            TabView(selection: $selection) {
                Input()
                    .tabItem {
                        Label("Input", systemImage: "star")
                    }
                    .tag(Tab.input)

                Expirables()
                    .environmentObject(sessionManager)
                    .tabItem {
                        Label("Expirables", systemImage: "list.bullet")
                    }
                    .tag(Tab.expirables)
            }
            .onAppear() {
                if #available(iOS 13.0, *) {
                    let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithDefaultBackground()
                    tabBarAppearance.backgroundColor = UIColor(Color.purple.opacity(0.5))
                    UITabBar.appearance().standardAppearance = tabBarAppearance

                    if #available(iOS 15.0, *) {
                        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    }
                }
            }
        } else {
            ZStack {
                Color.purple.opacity(0.4).ignoresSafeArea(.all)
                VStack {
                    Image("logo1")
                            .resizable()
                    switch sessionManager.authState {
                        case .logIn:
                            LogIn()
                                .environmentObject(sessionManager)
                        case .signUp:
                            SignUp()
                                .environmentObject(sessionManager)
                        case .confirmCode(let email):
                            Confirmation(email: email)
                                .environmentObject(sessionManager)
                        case .session(let user):
                            Session(user: user)
                                .environmentObject(sessionManager)
                                .onAppear() {
                                    modelData.showApp = true
                                    print("EMAIL: "+sessionManager.email)
                                    if Amplify.Auth.getCurrentUser()!.userId != "e0992cf2-de80-4371-8bd4-c8348b771daf" {
                                        var getRequest = URLRequest(url: URL(string: "https://tlqp0rmth1.execute-api.us-east-1.amazonaws.com/dev/userData?"+Amplify.Auth.getCurrentUser()!.userId)!)
                                        getRequest.httpMethod = "GET"
                                        getRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                        let getSession = URLSession.shared
                                        let getTask = getSession.dataTask(with: getRequest, completionHandler: { data, response, error -> Void in
                                            print(response!)
                                            do {
                                                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                                                print("json start")
                                                print(json)
                                                print("json end")
                                                if let jsonArray = json["Items"] as? [[String:Any]],
                                                   let items = jsonArray.first {
                                                    warningDays = items["warningDays"] as! Int
                                                    print(String(warningDays))
                                                }
                                                if let jsonArray = json["Items"] as? [[String:Any]],
                                                   let items = jsonArray.first {
                                                    email = items["email"] as! String
                                                    print(email)
                                                }
                                                if let jsonArray = json["Items"] as? [[String:Any]],
                                                   let items = jsonArray.first {
                                                    notifications = items["notifications"] as! Bool
                                                    print(notifications)
                                                }
                                                if let jsonArray = json["Items"] as? [[String:Any]],
                                                   let items = jsonArray.first {
                                                    categories = items["categories"] as! [String]
                                                    print(categories)
                                                }
                                                if let jsonArray = json["Items"] as? [[String:Any]],
                                                   let items = jsonArray.first {
                                                    sortType = items["sortType"] as! String
                                                    print(sortType)
                                                } else {
                                                    let params = ["userId": Amplify.Auth.getCurrentUser()!.userId, "email": sessionManager.email, "sortType": "expDate", "warningDays": "7", "notifications": "true", "categories": "[\"Allergy\", \"Bug Spray\", \"Pain Medicine\", \"Sunscreen\"]", "storage": "[[]]"] as! Dictionary<String, String>
                                                    var request = URLRequest(url: URL(string: "https://tlqp0rmth1.execute-api.us-east-1.amazonaws.com/dev/userData")!)
                                                    request.httpMethod = "POST"
                                                    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                                                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                    let session = URLSession.shared
                                                    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                                                        print(response!)
                                                        do {
                                                            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                                                            print(json)
                                                        } catch {
                                                            print("error")
                                                        }
                                                    })
                                                    task.resume()
                                                    storage = []
                                                }
                                                if let jsonArray = json["Items"] as? [[String:Any]],
                                                   let items = jsonArray.first {
                                                    temp = items["storage"] as! [[String]]
                                                    storage = []
                                                    dateFormatter.dateFormat = "MM/dd/yyyy"
                                                    if temp[0].count-1 >= 0 {
                                                        for i in 0...temp[0].count-1 {
                                                            print("Date")
                                                            print(temp[1][i])
                                                            print(dateFormatter.date(from: temp[1][i]))
                                                            storage.append(Expirable(name: temp[0][i], expDate: dateFormatter.date(from: temp[1][i]), alertStatus: Int(temp[2][i])!, category: temp[3][i], id: Int(temp[4][i])!))
                                                        }
                                                    }
                                                    for i in storage {
                                                        print("\(i)")
                                                    }
                                                }
                                                if email.count == 0 {
                                                    email = sessionManager.email
                                                }
                                                modelData.profile = Profile(email: email, userId: Amplify.Auth.getCurrentUser()?.userId ?? "error", sortType: sortType, warningDays: warningDays, notifications: notifications, categories: categories, storage: storage)
                                            } catch {
                                                print("error")
                                            }
                                        })
                                        getTask.resume()
                                    } else {
                                        print("GUEST")
                                        modelData.profile = Profile(email: "support@zeroexpiration.com", userId: "1", sortType: "expDate", warningDays: 7, notifications: false, categories: ["Allergy", "Bug Spray", "Ear Care", "Eye Care", "Pain Medicine", "Sunscreen"], storage: [])
                                    }
                                }
                        case .reset:
                            Reset()
                                .environmentObject(sessionManager)
                    }
                }
            }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}


