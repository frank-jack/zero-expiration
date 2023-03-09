//
//  Settings.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/23/22.
//

import SwiftUI
import Amplify

struct Settings: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentationMode
    let dateFormatter = DateFormatter()
    @State private var temp: [[String]] = [[],[],[],[],[]]
    @State private var showDelete = false
    @State private var expDateColor = Color.green
    @State private var nameColor = Color.blue
    @State var confirm = ""
    @State private var text1 = "Delete Account"
    @State private var warningDays = 1
    @State private var notifications = true
    @State private var categorySort = false
    @State private var category = ""
    @State private var text2 = ""
    @State private var showAdd = false
    @State private var showRemove = false
    var body: some View {
        ZStack {
            Color.purple.opacity(0.4).ignoresSafeArea(.all)
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                if !showDelete {
                    Button("Sort By Expiration Date") {
                        expDateColor = .green
                        nameColor = .blue
                        modelData.profile.sortType = "expDate"
                    }
                    .foregroundColor(expDateColor)
                    Button("Sort By Name") {
                        expDateColor = .blue
                        nameColor = .green
                        modelData.profile.sortType = "name"
                    }
                    .foregroundColor(nameColor)
                    HStack {
                        Text("Number of Warning Days: "+String(warningDays))
                        Slider(value: IntDoubleBinding($warningDays).doubleValue, in: 1.0...60.0, step: 1.0)
                    }
                    if modelData.profile.email != "support@zeroexpiration.com" {
                        Toggle("Send Email Notifications", isOn: $notifications)
                    }
                    Toggle("Sort with Categories", isOn: $categorySort)
                    VStack {
                        Text("Add or Remove Categories")
                        HStack {
                            Button {
                                showAdd = true
                                
                            } label: {
                                Label("", systemImage: "plus")
                            }
                            Button {
                                showRemove = true
                            } label: {
                                Label("", systemImage: "minus")
                            }
                        }
                        if showAdd {
                            TextField("Type Category to Add", text: $category)
                                .multilineTextAlignment(.center)
                            Button("Add New Category") {
                                if !modelData.profile.categories.contains(category) && category != "" {
                                    modelData.profile.categories.append(category)
                                    text2 = ""
                                } else {
                                    if category != "" {
                                        text2 = "This category already exists!"
                                    } else {
                                        text2 = "The category name is empty!"
                                    }
                                }
                                category = ""
                                showAdd = false
                            }
                        } else if showRemove {
                            Picker("Please choose a category", selection: $category) {
                                Text("Choose Category to Remove")
                                ForEach(modelData.profile.categories, id: \.self) {
                                    Text($0)
                                }
                            }
                            Button("Remove Category") {
                                if modelData.profile.categories.contains(category) && category != "" {
                                    modelData.profile.categories.remove(at: modelData.profile.categories.firstIndex(of: category)!)
                                    if modelData.profile.storage.count-1 >= 0 {
                                        for i in 0...modelData.profile.storage.count-1 {
                                            if modelData.profile.storage[i].category == category {
                                                modelData.profile.storage[i].category = ""
                                            }
                                        }
                                    }
                                    text2 = ""
                                } else {
                                    if category != "" {
                                        text2 = "This category does not exist!"
                                    } else {
                                        text2 = "No category was selected!"
                                    }
                                }
                                category = ""
                                showRemove = false
                            }
                        }
                        Text(text2)
                    }
                    Spacer()
                    VStack {
                        //Text(.init("[Privacy Policy](https://www.freeprivacypolicy.com/live/2f6355ec-5ec0-4ca8-8713-71c7c54828c9)"))
                        Text(.init("[Visit Our Website](http://zeroexpiration.com/)"))
                    }
                    Button("Sign Out") {
                        sessionManager.signOut()
                        modelData.showApp = false
                    }
                    if modelData.profile.email != "support@zeroexpiration.com" {
                        Button("Delete Account") {
                            showDelete = true
                        }
                        .foregroundColor(.red)
                    }
                } else {
                    Text("Delete Account")
                    TextField("Type 'CONFIRM'", text: $confirm)
                        .multilineTextAlignment(.center)
                    Button(text1) {
                        confirm = String(confirm.filter { !" \n\t\r".contains($0) })
                        if confirm == "CONFIRM" {
                            print("Ready to Delete")
                            if text1 == "Delete Account" {
                                text1 = "Are you sure?"
                            } else {
                                print("deleting")
                                Amplify.Auth.deleteUser()
                                presentationMode.wrappedValue.dismiss()
                                sessionManager.signOut()
                                modelData.showApp = false
                            }
                        }
                    }
                    .foregroundColor(.red)
                    Button("Cancel") {
                        showDelete = false
                        confirm = ""
                        text1 = "Delete Account"
                    }
                }
            }
            .padding()
            .onAppear() {
                dateFormatter.dateFormat = "MM/dd/yyyy"
                warningDays = modelData.profile.warningDays
                notifications = modelData.profile.notifications
                if modelData.profile.sortType == "nameC" || modelData.profile.sortType == "expDateC" {
                    categorySort = true
                } else {
                    categorySort = false
                }
                if modelData.profile.sortType == "expDate" || modelData.profile.sortType == "expDateC" {
                    expDateColor = Color.green
                    nameColor = Color.blue
                } else if modelData.profile.sortType == "name" || modelData.profile.sortType == "nameC"{
                    expDateColor = Color.blue
                    nameColor = Color.green
                }
            }
            .onDisappear() {
                modelData.profile.warningDays = warningDays
                modelData.profile.notifications = notifications
                if categorySort && (modelData.profile.sortType == "nameC" || modelData.profile.sortType == "name") {
                    modelData.profile.sortType = "nameC"
                } else if categorySort && (modelData.profile.sortType == "expDateC" || modelData.profile.sortType == "expDate") {
                    modelData.profile.sortType = "expDateC"
                } else if !categorySort && (modelData.profile.sortType == "nameC" || modelData.profile.sortType == "name") {
                    modelData.profile.sortType = "name"
                } else if !categorySort && (modelData.profile.sortType == "expDateC" || modelData.profile.sortType == "expDate") {
                    modelData.profile.sortType = "expDate"
                }
                if modelData.showApp {
                    if 0 <= modelData.profile.storage.count-1 {
                        temp = [[],[],[],[],[]]
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        for i in 0...modelData.profile.storage.count-1 {
                            temp[0].append(modelData.profile.storage[i].name)
                            temp[1].append(dateFormatter.string(from: modelData.profile.storage[i].expDate!))
                            temp[2].append(String(modelData.profile.storage[i].alertStatus))
                            temp[3].append(modelData.profile.storage[i].category)
                            temp[4].append(String(i))
                        }
                    }
                    let params = ["userId": modelData.profile.userId, "email": modelData.profile.email, "sortType": modelData.profile.sortType, "warningDays": String(modelData.profile.warningDays), "notifications": String(modelData.profile.notifications), "categories": modelData.profile.categories.description, "storage": temp.description] as! Dictionary<String, String>
                    var request = URLRequest(url: URL(string: "https://tlqp0rmth1.execute-api.us-east-1.amazonaws.com/dev/userData")!)
                    request.httpMethod = "PUT"
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
                }
            }
        }
    }
}

struct IntDoubleBinding {
    let intValue : Binding<Int>
    
    let doubleValue : Binding<Double>
    
    init(_ intValue : Binding<Int>) {
        self.intValue = intValue
        
        self.doubleValue = Binding<Double>(get: {
            return Double(intValue.wrappedValue)
        }, set: {
            intValue.wrappedValue = Int($0)
        })
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
