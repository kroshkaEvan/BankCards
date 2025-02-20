//
//  Wallet.swift
//  BankCards
//
//  Created by Evan Tsvetkov on 19.02.25.
//

import SwiftUI

final class Wallet: ObservableObject {
    
    @Published var cards: [Card]
        
    init(cards: [Card]) {
        self.cards = cards.reversed()
    }
    
    func index(of card: Card) -> Int {
        cards.count - cards.firstIndex(of: card)! - 1
    }
    
    func isFirst(card: Card) -> Bool {
        index(of: card) == 0
    }
}
