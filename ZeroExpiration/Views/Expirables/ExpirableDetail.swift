//
//  ExpirableDetail.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/22/22.
//

import SwiftUI

struct ExpirableDetail: View {
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentationMode
    let dateFormatter = DateFormatter()
    @State private var temp: [[String]] = [[],[],[],[],[]]
    @State private var tempId = -1
    @State private var text = "Delete Expirable"
    @State private var category = "-"
    @State private var expDate = ""
    var expirable: Expirable
    var body: some View {
        ZStack {
            Color.purple.opacity(0.4).ignoresSafeArea(.all)
            VStack {
                Text(expirable.name)
                Text(expDate)
                Picker("Change Category", selection: $category) {
                    ForEach(modelData.profile.categories, id: \.self) {
                        Text($0)
                    }
                    Text("Misc.").tag("")
                }
                .onChange(of: category) { newCategory in
                    print("Cat: "+category)
                    modelData.profile.storage[expirable.id].category = category
                    category = modelData.profile.storage[expirable.id].category
                    if modelData.profile.storage.count > 0 {
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
                    let params = ["userId": modelData.profile.userId, "email": modelData.profile.email, "sortType": modelData.profile.sortType,"warningDays": String(modelData.profile.warningDays), "notifications": String(modelData.profile.notifications), "categories": modelData.profile.categories.description, "storage": temp.description] as! Dictionary<String, String>
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
                Spacer()
                    .frame(height: UIScreen.main.bounds.height/8)
                if tempId != expirable.id {
                    if modelData.profile.storage[expirable.id].category != "" {
                        Image(String(modelData.profile.categories.firstIndex(where: {$0 == modelData.profile.storage[expirable.id].category})!%6))
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width*3/4, height: UIScreen.main.bounds.width*3/4)
                    } else {
                        Image("7")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width*3/4, height: UIScreen.main.bounds.width*3/4)
                    }
                }
                Spacer()
                Button(text) {
                    if text == "Delete Expirable" {
                        text = "Are You Sure?"
                    } else {
                        print("INDEX CHECK: "+String(expirable.id))
                        tempId = expirable.id
                        modelData.profile.storage.remove(at: expirable.id)
                        if tempId <= modelData.profile.storage.count-1 {
                            for i in tempId...modelData.profile.storage.count-1 {
                                print("ID CHECK: "+String(modelData.profile.storage[i].id))
                                modelData.profile.storage[i].id = modelData.profile.storage[i].id-1
                            }
                        }
                        if modelData.profile.storage.count > 0 {
                            temp = [[],[],[],[],[]]
                            dateFormatter.dateFormat = "MM/dd/yyyy"
                            for i in 0...modelData.profile.storage.count-1 {
                                temp[0].append(modelData.profile.storage[i].name)
                                temp[1].append(dateFormatter.string(from: modelData.profile.storage[i].expDate!))
                                temp[2].append(String(modelData.profile.storage[i].alertStatus))
                                temp[3].append(modelData.profile.storage[i].category)
                                temp[4].append(String(i))
                            }
                        } else {
                            temp = [[],[],[],[],[]]
                        }
                        let params = ["userId": modelData.profile.userId, "email": modelData.profile.email, "sortType": modelData.profile.sortType,"warningDays": String(modelData.profile.warningDays), "notifications": String(modelData.profile.notifications), "categories": modelData.profile.categories.description, "storage": temp.description] as! Dictionary<String, String>
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding()
                .foregroundColor(.red)
            }
            .onAppear() {
                dateFormatter.dateFormat = "MM/dd/yyyy"
                expDate = dateFormatter.string(from: modelData.profile.storage[expirable.id].expDate!)
                category = modelData.profile.storage[expirable.id].category
            }
        }
    }
}

/*struct ExpirableDetail_Previews: PreviewProvider {
    static var previews: some View {
        ExpirableDetail(expirable: <#Expirable#>)
            .environmentObject(ModelData())
    }
}*/
