//
//  Item.swift
//  BankCards
//
//  Created by Evan Tsvetkov on 19.02.25.
//

import Foundation
import SwiftData

@Model
final class Card {
    var name: String
    var number: String
    var limit: Int
    var month: Int
    var year: Int
    var firstColorData: Data?
    var secondColorData: Data?
    var timestamp: Date
    var paymentSystemRaw: String

    var paymentSystem: PaymentSystem {
        get { PaymentSystem(rawValue: paymentSystemRaw) ?? .mastercard }
        set { paymentSystemRaw = newValue.rawValue }
    }
    
    init(
        name: String,
        number: String,
        limit: Int,
        month: Int,
        year: Int,
        firstColorData: Data?,
        secondColorData: Data?,
        timestamp: Date,
        paymentSystem: PaymentSystem
    ) {
        self.name = name
        self.number = number
        self.limit = limit
        self.month = month
        self.year = year
        self.firstColorData = firstColorData
        self.secondColorData = secondColorData
        self.timestamp = timestamp
        self.paymentSystemRaw = paymentSystem.rawValue
    }
    
    static func defaultCard() -> Card {
        Card(
            name: "Evan",
            number: "4369 XXXX XXXX 5698",
            limit: 12000,
            month: 02,
            year: 2025,
            firstColorData: nil,
            secondColorData: nil,
            timestamp: Date(),
            paymentSystem: .visa
        )
    }
}

enum PaymentSystem: String, Codable {
    case visa = "Visa"
    case mastercard = "Mastercard"
    case unionPay = "UnionPay"
}
