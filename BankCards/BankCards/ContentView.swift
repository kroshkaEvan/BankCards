//
//  ContentView.swift
//  BankCards
//
//  Created by Evan Tsvetkov on 19.02.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \Card.timestamp, order: .reverse)
    private var cards: [Card]

    @State
    private var shouldPresentCardForm = false
    @State
    private var shouldShowTransactionForm = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentCardForm) {
                        AddBankCard()
                    }
                Spacer()
                
                if cards.isEmpty {
                    EmptyCardView(shouldPresentCardForm: $shouldPresentCardForm)
                } else {
                    Spacer()
                    
                    WalletView()
                        .environmentObject(Wallet(cards: cards))
                        .frame(height: 600)
                }
            }
            .navigationTitle("My Wallet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DeleteItemButton(cards: cards, modelContext: modelContext)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    AddCardButton(shouldPresentCardForm: $shouldPresentCardForm)
                }
            }
            .background {
                LinearGradient(
                    gradient: Gradient(colors: [.mint, .black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - 🔹 Blank screen if there are no cards

struct EmptyCardView: View {
    @Binding
    var shouldPresentCardForm: Bool
    
    var body: some View {
        VStack {
            Text("You currently have no cards in the system")
                .padding(.horizontal, 50)
                .padding(.vertical)
                .multilineTextAlignment(.center)
            
            Button {
                shouldPresentCardForm.toggle()
            } label: {
                Text("+ Add first card")
                    .foregroundColor(.white)
                    .font(.system(size: 25, weight: .bold))
            }
            .padding(15)
            .background(Color.blue)
            .cornerRadius(10)
            
            Spacer()
        }
        .font(.system(size: 24, weight: .semibold, design: .monospaced))
    }
}

// MARK: - 🔹 "Add Card” button

struct AddCardButton: View {
    @Binding
    var shouldPresentCardForm: Bool

    var body: some View {
        Button {
            shouldPresentCardForm.toggle()
        } label: {
            Text("+ Card")
                .font(.system(size: 16, weight: .semibold))
                .cornerRadius(7)
        }
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - 🔹 Delete all cards button

struct DeleteItemButton: View {
    let cards: [Card]
    let modelContext: ModelContext

    var body: some View {
        Button {
            withAnimation {
                for card in cards {
                    modelContext.delete(card)
                }
                
                do {
                    try modelContext.save()
                } catch {
                    print("Error deleting cards: \(error)")
                }
            }
        } label: {
            Text("Delete all cards")
                .font(.system(size: 16, weight: .semibold))
                .cornerRadius(7)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Card.self, inMemory: true)
}
