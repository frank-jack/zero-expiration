//
//  Expirables.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/22/22.
//

import SwiftUI
import Foundation

struct Expirables: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var sessionManager: SessionManager
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    let dateFormatter = DateFormatter()
    @State private var sortedByDate: [Expirable] = []
    @State private var sortedByName: [Expirable] = []
    @State private var expired: [Int] = []
    @State private var warned: [Int] = []
    @State private var sorted = false
    @State private var temp = Expirable(name: "", expDate: Date(), alertStatus: -1, category: "", id: -1)
    @State private var showSettings = false
    var body: some View {
        NavigationView {
            List {
                if modelData.profile.sortType == "expDate" {
                    ForEach(sortedByDate) { expirable in
                        if warned.contains(expirable.id) {
                            NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                ExpirableLabel(expirable: expirable)
                            }
                            .listRowBackground(Color.yellow)
                        } else if expired.contains(expirable.id) {
                            NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                ExpirableLabel(expirable: expirable)
                            }
                            .listRowBackground(Color.red)
                        } else {
                            NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                ExpirableLabel(expirable: expirable)
                            }
                        }
                    }
                }
                if modelData.profile.sortType == "name" {
                    ForEach(sortedByName) { expirable in
                        if warned.contains(expirable.id) {
                            NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                ExpirableLabel(expirable: expirable)
                            }
                            .listRowBackground(Color.yellow)
                        } else if expired.contains(expirable.id) {
                            NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                ExpirableLabel(expirable: expirable)
                            }
                            .listRowBackground(Color.red)
                        } else {
                            NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                ExpirableLabel(expirable: expirable)
                            }
                        }
                    }
                }
                if modelData.profile.sortType == "expDateC" {
                    ForEach(modelData.profile.categories, id: \.self) { category in
                        Section(header: HStack{Image(String(modelData.profile.categories.firstIndex(where: {$0 == category})!%6)).resizable().frame(width: 30, height: 30);Text(category)}) {
                            ForEach(sortedByDate) { expirable in
                                if expirable.category == category {
                                    if warned.contains(expirable.id) {
                                        NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                            ExpirableLabel(expirable: expirable)
                                        }
                                        .listRowBackground(Color.yellow)
                                    } else if expired.contains(expirable.id) {
                                        NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                            ExpirableLabel(expirable: expirable)
                                        }
                                        .listRowBackground(Color.red)
                                    } else {
                                        NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                            ExpirableLabel(expirable: expirable)
                                        }
                                    }
                                }
                            }
                        }
                        .headerProminence(.increased)
                    }
                    Section(header: HStack{Image("7").resizable().frame(width: 30, height: 30);Text("Misc.")}) {
                        ForEach(sortedByDate) { expirable in
                            if expirable.category == "" {
                                if warned.contains(expirable.id) {
                                    NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                        ExpirableLabel(expirable: expirable)
                                    }
                                    .listRowBackground(Color.yellow)
                                } else if expired.contains(expirable.id) {
                                    NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                        ExpirableLabel(expirable: expirable)
                                    }
                                    .listRowBackground(Color.red)
                                } else {
                                    NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                        ExpirableLabel(expirable: expirable)
                                    }
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
                if modelData.profile.sortType == "nameC" {
                    ForEach(modelData.profile.categories, id: \.self) { category in
                        Section(header: HStack{Image(String(modelData.profile.categories.firstIndex(where: {$0 == category})!%6)).resizable().frame(width: 30, height: 30);Text(category)}) {
                            ForEach(sortedByName) { expirable in
                                if expirable.category == category {
                                    if warned.contains(expirable.id) {
                                        NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                            ExpirableLabel(expirable: expirable)
                                        }
                                        .listRowBackground(Color.yellow)
                                    } else if expired.contains(expirable.id) {
                                        NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                            ExpirableLabel(expirable: expirable)
                                        }
                                        .listRowBackground(Color.red)
                                    } else {
                                        NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                            ExpirableLabel(expirable: expirable)
                                        }
                                    }
                                }
                            }
                        }
                        .headerProminence(.increased)
                    }
                    Section(header: HStack{Image("7").resizable().frame(width: 30, height: 30);Text("Misc.")}) {
                        ForEach(sortedByName) { expirable in
                            if expirable.category == "" {
                                if warned.contains(expirable.id) {
                                    NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                        ExpirableLabel(expirable: expirable)
                                    }
                                    .listRowBackground(Color.yellow)
                                } else if expired.contains(expirable.id) {
                                    NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                        ExpirableLabel(expirable: expirable)
                                    }
                                    .listRowBackground(Color.red)
                                } else {
                                    NavigationLink(destination: ExpirableDetail(expirable: expirable)) {
                                        ExpirableLabel(expirable: expirable)
                                    }
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .onAppear() {
                let coloredAppearance = UINavigationBarAppearance()
                coloredAppearance.configureWithOpaqueBackground()
                coloredAppearance.backgroundColor = UIColor(Color.purple.opacity(0.5))
                UINavigationBar.appearance().standardAppearance = coloredAppearance
                UINavigationBar.appearance().compactAppearance = coloredAppearance
            }
            .listStyle(.insetGrouped)
            .background(Color.purple.opacity(0.4).ignoresSafeArea(.all))
            .navigationTitle("Expirables")
            .toolbar {
                ToolbarItem {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                Settings()
                    .environmentObject(sessionManager)
                    .onDisappear() {
                        if 0 <= modelData.profile.storage.count - 1 {
                            expired = []
                            for i in 0...modelData.profile.storage.count - 1 {
                                if modelData.profile.storage[i].expDate! <= Date() {
                                    expired.append(i)
                                }
                            }
                            print("EXPIRED: ")
                            print(expired)
                            
                            warned = []
                            for i in 0...modelData.profile.storage.count - 1 {
                                if !expired.contains(i) && Calendar.current.dateComponents([.day], from: Date(), to: modelData.profile.storage[i].expDate!).day! <= modelData.profile.warningDays {
                                    warned.append(i)
                                }
                            }
                            print("WARNED: ")
                            print(warned)
                        }
                    }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: modelData.profile.storage) { newStorage in
            setUp()
        }
        .onAppear {
            setUp()
        }
    }
    func setUp() {
        dateFormatter.dateFormat = "MM/dd/yyyy"
        sortedByDate = []
        sortedByName = []
        sortedByDate = modelData.profile.storage
        sortedByName = modelData.profile.storage
        print("STORAGE: ")
        print(modelData.profile.storage)
        if modelData.profile.storage.count > 1 {
            while(!sorted) {
                sorted = true
                for i in 0...sortedByDate.count-2 {
                    if sortedByDate[i].expDate! > sortedByDate[i+1].expDate! {
                        temp = sortedByDate[i]
                        sortedByDate[i] = sortedByDate[i+1]
                        sortedByDate[i+1] = temp
                        sorted = false
                    }
                }
            }
            sorted = false
            while(!sorted) {
                sorted = true
                for i in 0...sortedByName.count-2 {
                    if sortedByName[i].name > sortedByName[i+1].name {
                        temp = sortedByName[i]
                        sortedByName[i] = sortedByName[i+1]
                        sortedByName[i+1] = temp
                        sorted = false
                    }
                }
            }
            sorted = false
        }
        print(sortedByDate)
        print(sortedByName)
        if 0 <= modelData.profile.storage.count - 1 {
            expired = []
            for i in 0...modelData.profile.storage.count - 1 {
                if modelData.profile.storage[i].expDate! <= Date() {
                    expired.append(i)
                }
            }
            print("EXPIRED: ")
            print(expired)
            
            warned = []
            for i in 0...modelData.profile.storage.count - 1 {
                if !expired.contains(i) && Calendar.current.dateComponents([.day], from: Date(), to: modelData.profile.storage[i].expDate!).day! <= modelData.profile.warningDays {
                    warned.append(i)
                }
            }
            print("WARNED: ")
            print(warned)
        }
    }
}


struct Expirables_Previews: PreviewProvider {
    static var previews: some View {
        Expirables()
            .environmentObject(ModelData())
    }
}
