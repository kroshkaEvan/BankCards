//
//  UIColor+.swift
//  BankCards
//
//  Created by Evan Tsvetkov on 19.02.25.
//

import UIKit
import SwiftUI

extension UIColor {
    static func color(data: Data) -> UIColor?{
        return try?
        NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
    
    func encode() -> Data? {
        return try?
        NSKeyedArchiver.archivedData(withRootObject: self,
                                     requiringSecureCoding: false)
    }
}

extension Color: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        
        do {
            if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                self = Color(color)
            } else {
                self = .black
            }
        } catch {
            self = .black
        }
    }
    
    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

extension Color {
    init?(data: Data) {
        guard let uiColor = UIColor.color(data: data) else { return nil }
        self = Color(uiColor)
    }
    
    func toData() -> Data? {
        UIColor(self).toData()
    }
}

extension UIColor {
    func toData() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: .whitespacesAndNewlines))
        if hex.hasPrefix("#") { scanner.currentIndex = hex.index(after: hex.startIndex) }
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
