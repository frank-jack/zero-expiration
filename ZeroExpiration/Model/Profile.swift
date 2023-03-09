//
//  Profile.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/23/22.
//

import Foundation

struct Profile {
    var email: String
    var userId: String
    var sortType: String
    var warningDays: Int
    var notifications: Bool
    var categories: [String]
    var storage: [Expirable]

    static let `default` = Profile(email: "default", userId: "", sortType: "expDate", warningDays: 7, notifications: true, categories: ["Allergy", "Bug Spray", "Ear Care", "Eye Care", "Pain Medicine", "Sunscreen"], storage: [])

}

