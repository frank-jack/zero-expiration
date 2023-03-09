//
//  Expirable.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/22/22.
//

import Foundation

struct Expirable: Hashable, Identifiable {
    var name: String
    var expDate: Date?
    var alertStatus: Int
    var category: String
    var id: Int
}
