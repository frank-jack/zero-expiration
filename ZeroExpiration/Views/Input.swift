//
//  Input.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/22/22.
//

import SwiftUI
import VisionKit

struct Input: View {
    @EnvironmentObject var modelData: ModelData
    let dateFormatter = DateFormatter()
    @State var name = ""
    @State var expDate = Date()
    @State var strExpDate = ""
    @State var category = ""
    @State private var temp: [[String]] = [[],[],[],[],[]]
    @State private var text = ""
    @State private var recognizedText = ""
    @State private var showingScanningView = false
    @State private var sortText = ""
    @State private var iOfSlash: [Int] = []
    @State private var datesInText: [String] = []
    @State private var trueDates: [Date] = []
    @State private var tempMonth = ""
    @State private var tempDay = ""
    @State private var tempYear = ""
    @State private var sorted = false
    @State private var tempSort = Date()
    @State private var showText = false
    var body: some View {
        ZStack {
            Color.purple.opacity(0.4).ignoresSafeArea(.all)
            VStack {
                Text("Input")
                    .font(.largeTitle)
                    .bold()
                Text("New Expirables")
                VStack {
                    TextField("Expirable Name", text: $name)
                        .multilineTextAlignment(.center)
                    Picker("Please choose a category", selection: $category) {
                        Text("Choose Category for Expirable")
                        ForEach(modelData.profile.categories, id: \.self) {
                            Text($0)
                        }
                    }
                    DatePicker(selection: $expDate, displayedComponents: .date) {
                        Text("Pick the Expiration Date")
                    }
                    .id(expDate)
                    Button(action: {
                        self.showingScanningView = true
                    }, label: {
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                            
                            Text("Scan for Expiration Date")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(Color(UIColor.systemIndigo))
                        .cornerRadius(18)
                    })
                    if trueDates.count > 0 {
                        Picker("Please choose a date", selection: $expDate) {
                            Text("Choose Expiration Date from Scan")
                            ForEach(trueDates, id: \.self) {
                                Text(dateFormatter.string(from: $0))
                            }
                        }
                    }
                    Button("Submit") {
                        if name != "" {
                            recognizedText = ""
                            modelData.profile.storage.append(Expirable(name: name, expDate: expDate, alertStatus: 0, category: category, id: modelData.profile.storage.count))
                            temp = [[],[],[],[],[]]
                            dateFormatter.dateFormat = "MM/dd/yyyy"
                            for i in 0...modelData.profile.storage.count-1 {
                                temp[0].append(modelData.profile.storage[i].name)
                                temp[1].append(dateFormatter.string(from: modelData.profile.storage[i].expDate!))
                                temp[2].append(String(modelData.profile.storage[i].alertStatus))
                                temp[3].append(modelData.profile.storage[i].category)
                                temp[4].append(String(i))
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
                            name = ""
                            expDate = Date()
                            category = ""
                            text = ""
                        } else {
                            text = "Missing Name!"
                        }
                    }
                    Text(text)
                        .onChange(of: recognizedText) { newValue in
                            sortText = "       "+String(recognizedText.filter { !" \n\t\r".contains($0) })+"       "
                            iOfSlash = []
                            datesInText = []
                            trueDates = []
                            if 0 <= sortText.count-1 {
                                for i in 0...sortText.count-1 {
                                    if sortText[sortText.index(sortText.startIndex, offsetBy: i)] == "/" {
                                        iOfSlash.append(i)
                                    }
                                }
                            }
                            print(sortText)
                            print(iOfSlash)
                            for i in iOfSlash {
                                tempMonth = ""
                                tempDay = ""
                                tempYear = ""
                                if iOfSlash.contains(i+3) {
                                    if isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i-2)])) {
                                        tempMonth = String(sortText[sortText.index(sortText.startIndex, offsetBy: i-2)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i-1)])
                                    } else {
                                        tempMonth = "0"+String(sortText[sortText.index(sortText.startIndex, offsetBy: i-1)])
                                    }
                                    tempDay = String(sortText[sortText.index(sortText.startIndex, offsetBy: i+1)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+2)])
                                    if isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+6)])) && isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+7)])) {
                                        tempYear = String(sortText[sortText.index(sortText.startIndex, offsetBy: i+4)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+5)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+6)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+7)])
                                    } else {
                                        tempYear = "20"+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+4)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+5)])
                                    }
                                }
                                if iOfSlash.contains(i+2) {
                                    if isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i-2)])) {
                                        tempMonth = String(sortText[sortText.index(sortText.startIndex, offsetBy: i-2)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i-1)])
                                    } else {
                                        tempMonth = "0"+String(sortText[sortText.index(sortText.startIndex, offsetBy: i-1)])
                                    }
                                    tempDay = "0"+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+1)])
                                    if isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+5)])) && isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+6)])) {
                                        tempYear = String(sortText[sortText.index(sortText.startIndex, offsetBy: i+3)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+4)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+5)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+6)])
                                    } else {
                                        tempYear = "20"+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+3)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+4)])
                                    }
                                }
                                if !iOfSlash.contains(i+3) && !iOfSlash.contains(i+2) && !iOfSlash.contains(i-3) && !iOfSlash.contains(i-2) && isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i-1)])) && isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+1)])) && isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+2)])) {
                                    if isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i-2)])) {
                                        tempMonth = String(sortText[sortText.index(sortText.startIndex, offsetBy: i-2)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i-1)])
                                    } else {
                                        tempMonth = "0"+String(sortText[sortText.index(sortText.startIndex, offsetBy: i-1)])
                                    }
                                    tempDay = "01"
                                    if isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+3)])) && isValidNumber(string: String(sortText[sortText.index(sortText.startIndex, offsetBy: i+4)])) {
                                        tempYear = String(sortText[sortText.index(sortText.startIndex, offsetBy: i+1)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+2)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+3)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+4)])
                                    } else {
                                        tempYear = "20"+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+1)])+String(sortText[sortText.index(sortText.startIndex, offsetBy: i+2)])
                                    }
                                }
                                print(tempMonth)
                                print(tempDay)
                                print(tempYear)
                                if tempMonth.count == 2 && tempDay.count == 2 && tempYear.count == 4 {
                                    if Int(tempMonth)! <= 12 {
                                        datesInText.append(tempMonth+"/"+tempDay+"/"+tempYear)
                                    }
                                }
                            }
                            print(datesInText)
                            for i in datesInText {
                                trueDates.append(dateFormatter.date(from: i)!)
                            }
                            if trueDates.count > 1 {
                                while(!sorted) {
                                    sorted = true
                                    for i in 0...trueDates.count-2 {
                                        if trueDates[i] > trueDates[i+1] {
                                            tempSort = trueDates[i]
                                            trueDates[i] = trueDates[i+1]
                                            trueDates[i+1] = tempSort
                                            sorted = false
                                        }
                                    }
                                }
                                sorted = false
                            }
                        }
                    if recognizedText.count > 0 {
                        if showText {
                            Button("Hide Scanned Text") {
                                showText = false
                            }
                            Text(recognizedText)
                        } else {
                            Button("See Scanned Text") {
                                showText = true
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingScanningView) {
                    ScanDocumentView(recognizedText: self.$recognizedText)
                }
                .padding()
                .onAppear() {
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    text = ""
                    print("PROFILE:")
                    print(modelData.profile)
                }
            }
        }
    }
}

func isValidNumber(string: String) -> Bool {
    for char in string {
        let scalarValues = String(char).unicodeScalars
        let charAscii = scalarValues[scalarValues.startIndex].value
        //ASCII value of 0 = 48, 9 = 57. So if value is outside of numeric range then fail
        //Checking for negative sign "-" could be added: ASCII value 45.
        if charAscii < 48 || charAscii > 57 {
            return false
        }
    }
    return true
}

struct Input_Previews: PreviewProvider {
    static var previews: some View {
        Input()
    }
}
