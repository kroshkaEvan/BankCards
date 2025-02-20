//
//  WalletView.swift
//  BankCards
//
//  Created by Evan Tsvetkov on 19.02.25.
//

import SwiftUI

struct WalletView: View {
    
    enum Constants {
        static let cardTransitionDelay: Double = 0.2
        static let cardOffset: CGFloat = -20
        static let cardOpacity: Double = 0.05
        static let cardShrinkRatio: CGFloat = 0.05
        static let cardRotationAngle: Double = 30
        static let cardScaleWhenDragginDown: CGFloat = 1.1
        static let padding: CGFloat = 20
        static let aspectRatio: Double = 16 / 9
    }
    
    @EnvironmentObject
    var wallet: Wallet
    @State
    private var draggingOffset: CGFloat = 0
    @State
    private var isDragging: Bool = false
    @State
    private var firstCardScale: CGFloat = Constants.cardScaleWhenDragginDown
    @State
    private var isPresented = false
    @State
    private var shouldDelay = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isPresented {
                    ForEach(wallet.cards) { card in
                        BankCardView(card: card)
                            .opacity(opacity(for: card))
                            .offset(x: 0,
                                    y: offset(for: card))
                            .scaleEffect(scaleEffect(for: card))
                            .rotation3DEffect(rotationAngle(for: card),
                                              axis: (x: 0.5, y: 1, z: 0))
                            .gesture(
                                DragGesture()
                                    .onChanged({ (value) in
                                        dragGestureDidChange(value: value,
                                                             card: card,
                                                             geometry: geometry)
                                    })
                                    .onEnded({ (value) in
                                        dragGestureDidEnd(value: value,
                                                          card: card,
                                                          geometry: geometry)
                                    }))
                            .onTapGesture {
                                let newCards = wallet.cards.filter { $0 != card } + [card]
                                wallet.cards = newCards
                            }
                            .transition(.moveUpWardsWhileFadingIn)
                            .animation(.easeOut.delay(transitionDelay(card: card)))
                    }.onAppear {
                        shouldDelay = false
                    }
                }
            }
            .onAppear {
                isPresented.toggle()
            }
            .padding(.horizontal, Constants.padding)
        }
    }
}

// MARK: - 🔹 Dragging

extension WalletView {
    
    func dragGestureDidChange(value: DragGesture.Value, card: Card, geometry: GeometryProxy) {
        guard wallet.isFirst(card: card) else { return }
        
        draggingOffset = value.translation.height
        isDragging = true
        firstCardScale = newFirstCardScale(geometry: geometry)
    }
    
    func dragGestureDidEnd(value: DragGesture.Value, card: Card, geometry: GeometryProxy) {
        guard wallet.isFirst(card: card) else { return }
        
        draggingOffset = 0
        wallet.cards = cardsResortedAfterTranslation(draggedCard: card, yTranslation: value.translation.height, geometry: geometry)
        isDragging = false
    }
    
}

// MARK: - 🔹 Helper functions

extension WalletView {
    
    private func cardsResortedAfterTranslation(draggedCard card: Card, yTranslation: CGFloat, geometry: GeometryProxy) -> [Card] {
        let cardHeight = (geometry.size.width / CGFloat(Constants.aspectRatio) - Constants.padding)
        if abs(yTranslation + CGFloat(wallet.cards.count) * -Constants.cardOffset) > cardHeight {
            let newCards = [card] + Array(wallet.cards.dropLast())
            
            return newCards
        }
        
        return wallet.cards
    }
    
    private func newFirstCardScale(geometry: GeometryProxy) -> CGFloat {
        if draggingOffset > 0 {
            let newScale = 1 + draggingOffset / (1.5 * geometry.size.height)
            
            return min(Constants.cardScaleWhenDragginDown, newScale)
        } else {
            let newScale = 1 + draggingOffset / (1.5 * geometry.size.height)
            
            return max(1 - CGFloat(wallet.cards.count) * Constants.cardShrinkRatio, newScale)
        }
    }
    
    private func transitionDelay(card: Card) -> Double {
        guard shouldDelay else { return 0 }
        
        return Double(wallet.index(of: card)) * Constants.cardTransitionDelay
    }
    
    private func opacity(for card: Card) -> Double {
        let cardIndex = Double(wallet.index(of: card))
        
        return 1 - cardIndex * Constants.cardOpacity
    }
    
    private func offset(for card: Card) -> CGFloat {
        guard !wallet.isFirst(card: card) else { return draggingOffset }
        
        let cardIndex = CGFloat(wallet.index(of: card))
        
        return cardIndex * Constants.cardOffset
    }
    
    private func scaleEffect(for card: Card) -> CGFloat {
        guard !(isDragging && wallet.isFirst(card: card)) else { return firstCardScale }
        
        let cardIndex = CGFloat(wallet.index(of: card))
        
        return 1 - cardIndex * Constants.cardShrinkRatio
    }
    
    private func rotationAngle(for card: Card) -> Angle {
        guard !wallet.isFirst(card: card) && !isDragging else { return .zero }
        
        return Angle(degrees: Constants.cardRotationAngle)
    }
}

extension AnyTransition {
    static var moveUpWardsWhileFadingIn: AnyTransition {
        AnyTransition.move(edge: .bottom).combined(with: .opacity)
    }
}

#Preview {
    WalletView()
}
