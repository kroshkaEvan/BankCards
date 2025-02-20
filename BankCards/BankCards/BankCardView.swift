//
//  BankCardView.swift
//  BankCards
//
//  Created by Evan Tsvetkov on 19.02.25.
//

import SwiftUI
import SwiftData

struct BankCardView: View {
    let card: Card
    
    @State
    private var shouldShowActionSheet = false
    @State
    private var shouldShowEditForm = false
    @State
    private var refreshID = UUID()
    
    @SceneStorage("isCardDeleted")
    private var isCardDeleted: Bool = false
    @ScaledMetric
    private var scaledFontSize: CGFloat = 25
    
    @Environment(\.modelContext)
    private var modelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeader(card: card,
                       fontSize: scaledFontSize,
                       didTapDelete: didTapDelete,
                       shouldShowActionSheet: $shouldShowActionSheet,
                       shouldShowEditForm: $shouldShowEditForm)
            
            CardBalanceView(card: card)
            CardNumberView(card: card)
            CardCreditLimitView(card: card)
        }
        .padding()
        .background(CardBackgroundView(card: card))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.yellow, lineWidth: 2)
        )
        .foregroundColor(.white)
        .cornerRadius(10)
        .shadow(color: .gray, radius: 8)
        .padding(.horizontal)
        .padding(.top, 8)
        .id(refreshID)
        .sheet(isPresented: $shouldShowEditForm) {
            Text("Edit Form Placeholder")
        }
    }
}

// MARK: - 🔹 Private methods

extension BankCardView {
    private func didTapDelete() {
        modelContext.delete(card)
        isCardDeleted = true
        refreshID = UUID()
    }
}

// MARK: - 🔹 Card header (Name + action button)

struct CardHeader: View {
    let card: Card
    let fontSize: CGFloat
    let didTapDelete: () -> Void

    @Binding
    var shouldShowActionSheet: Bool
    @Binding
    var shouldShowEditForm: Bool
    
    var body: some View {
        HStack {
            Text(card.name)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
            Spacer()
            Button {
                shouldShowActionSheet.toggle()
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
            }
            .actionSheet(isPresented: $shouldShowActionSheet) {
                ActionSheet(
                    title: Text(card.name),
                    message: Text("Options"),
                    buttons: [
                        .default(Text("Edit"), action: { shouldShowEditForm.toggle() }),
                        .destructive(Text("Delete card"), action: didTapDelete),
                        .cancel()
                    ]
                )
            }
        }
    }
}

// MARK: - 🔹 Card balance

struct CardBalanceView: View {
    let card: Card
    
    var body: some View {
        HStack {
            Image(card.paymentSystemRaw)
                .resizable()
                .clipped()
                .scaledToFit()
                .frame(height: 70)
            Spacer()
            Text("Balance: \(Int.random(in: 1...300)),000 $")
                .font(.system(size: 18, weight: .semibold))
        }
    }
}

// MARK: - 🔹 Card Number

struct CardNumberView: View {
    let card: Card
    
    var body: some View {
        Text(card.number)
            .font(.system(size: 18, weight: .semibold))
    }
}

// MARK: - 🔹 Credit Limit

struct CardCreditLimitView: View {
    let card: Card
    
    var body: some View {
        Text("Credit limit: \(card.limit) $")
    }
}

// MARK: - 🔹 Card background

struct CardBackgroundView: View {
    let card: Card

    var body: some View {
        VStack {
            let firstColor = Color(data: card.firstColorData ?? Data()) ?? .pink
            let secondColor = Color(data: card.secondColorData ?? Data()) ?? .blue
            LinearGradient(
                gradient: Gradient(colors: [firstColor, secondColor]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
}

#Preview {
    BankCardView(
        card: Card.defaultCard()
    )
}
