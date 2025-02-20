//
//  AddBankCard.swift
//  BankCards
//
//  Created by Evan Tsvetkov on 19.02.25.
//

import SwiftUI
import SwiftData

struct AddBankCard: View {
    @Environment(\.presentationMode)
    var presentationMode
    @Environment(\.modelContext)
    private var modelContext
    
    let card: Card?
    
    @State
    private var name: String
    @State
    private var limit: String
    @State
    private var cardNumber: String
    @State
    private var paymentSystem: PaymentSystem
    @State
    private var month: Int
    @State
    private var year: Int
    @State
    private var firstColor: Color
    @State
    private var secondColor: Color
    
    private let currentYear = Calendar.current.component(.year, from: Date())
    
    init(card: Card? = nil) {
        self.card = card
        _name = State(initialValue: card?.name ?? "")
        _cardNumber = State(initialValue: card?.number ?? "")
        _limit = State(initialValue: String(card?.limit ?? 0))
        _month = State(initialValue: Int(card?.month ?? 1))
        _year = State(initialValue: Int(card?.year ?? currentYear))
        _paymentSystem = State(initialValue: card?.paymentSystem ?? .mastercard)
        
        let defaultFirstColor = Color(data: card?.firstColorData ?? Data()) ?? .pink
        let defaultSecondColor = Color(data: card?.secondColorData ?? Data()) ?? .blue
        
        _firstColor = State(initialValue: defaultFirstColor)
        _secondColor = State(initialValue: defaultSecondColor)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                CardInfoSection(name: $name, cardNumber: $cardNumber, limit: $limit, paymentSystem: $paymentSystem)
                ExpirationDateSection(month: $month, year: $year, currentYear: currentYear)
                CardColorSection(firstColor: $firstColor, secondColor: $secondColor)
            }
            .navigationTitle(card != nil ? (card?.name ?? "Edit Card") : "Add Credit Card")
            .navigationBarItems(
                leading: cancelButton(presentationMode: presentationMode),
                trailing: saveButton(
                    name: $name,
                    cardNumber: $cardNumber,
                    limit: $limit,
                    month: $month,
                    year: $year,
                    firstColor: $firstColor,
                    secondColor: $secondColor,
                    paymentSystem: $paymentSystem,
                    card: card,
                    modelContext: modelContext,
                    presentationMode: presentationMode
                )
            )
        }
    }
}

// MARK: - 🔹 Card information section

struct CardInfoSection: View {
    @Binding
    var name: String
    @Binding
    var cardNumber: String
    @Binding
    var limit: String
    @Binding
    var paymentSystem: PaymentSystem
    
    var body: some View {
        Section(header: Text("Card Information")) {
            TextField("Name", text: $name)
            TextField("Card Number", text: $cardNumber)
                .keyboardType(.numberPad)
            TextField("Credit Limit", text: $limit)
                .keyboardType(.numberPad)
            Picker("Payment System", selection: $paymentSystem) {
                ForEach([PaymentSystem.mastercard, .visa, .unionPay], id: \.self) { system in
                    Text(system.rawValue).tag(system)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - 🔹 Card expiration date section

struct ExpirationDateSection: View {
    @Binding
    var month: Int
    @Binding
    var year: Int
    
    let currentYear: Int
    
    var body: some View {
        Section(header: Text("Expiration Date")) {
            Picker("Month", selection: $month) {
                ForEach(1...12, id: \.self) { Text("\($0)").tag($0) }
            }
            Picker("Year", selection: $year) {
                ForEach(currentYear...(currentYear + 10), id: \.self) { Text("\($0)").tag($0) }
            }
        }
    }
}

// MARK: - 🔹 Card color selection section

struct CardColorSection: View {
    @Binding
    var firstColor: Color
    
    @Binding
    var secondColor: Color
    
    var body: some View {
        Section(header: Text("Card Color")) {
            ColorPicker("First Color", selection: $firstColor)
            ColorPicker("Second Color", selection: $secondColor)
        }
    }
}

// MARK: - 🔹 Navigation buttons (Save / Cancel)

extension AddBankCard {
    @ViewBuilder
    private func cancelButton(presentationMode: Binding<PresentationMode>) -> some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    @ViewBuilder
    private func saveButton(
        name: Binding<String>,
        cardNumber: Binding<String>,
        limit: Binding<String>,
        month: Binding<Int>,
        year: Binding<Int>,
        firstColor: Binding<Color>,
        secondColor: Binding<Color>,
        paymentSystem: Binding<PaymentSystem>,
        card: Card?,
        modelContext: ModelContext,
        presentationMode: Binding<PresentationMode>
    ) -> some View {
        Button("Save") {
            let newCard = card ?? Card.defaultCard()
            newCard.name = name.wrappedValue
            newCard.timestamp = Date()
            newCard.year = year.wrappedValue
            newCard.month = month.wrappedValue
            newCard.limit = Int(limit.wrappedValue) ?? 0
            newCard.number = cardNumber.wrappedValue
            newCard.firstColorData = firstColor.wrappedValue.toData()
            newCard.secondColorData = secondColor.wrappedValue.toData()
            newCard.paymentSystem = paymentSystem.wrappedValue
            
            modelContext.insert(newCard)
            
            do {
                try modelContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error saving card: \(error)")
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    AddBankCard()
}
