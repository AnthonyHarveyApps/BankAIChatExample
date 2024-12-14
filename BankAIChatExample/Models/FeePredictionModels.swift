//
//  FeePredictionModels.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import Foundation

enum FeeType: String, Codable {
    case fixed = "Fixed Fee"
    case percentage = "Percentage Fee"
    case exchangeRateMarkup = "Exchange Rate Markup"
}

struct PredictedFee: Codable, Identifiable {
    let id: UUID
    let type: FeeType
    let amount: Decimal
    let currency: String
    let description: String?
    
    /// Returns a concise readable summary of the fee
    func summary() -> String {
        let descriptionText = description ?? "No description provided"
        return "\(type.rawValue): \(currency) \(amount) (\(descriptionText))"
    }
}

struct CurrencyExchangeDetails: Codable {
    let fromCurrency: String
    let toCurrency: String
    let exchangeRate: Decimal
    let exchangeRateMarkup: Decimal
}

struct InternationalTransferFeePrediction: Codable {
    let transferAmount: Decimal
    let fromCurrency: String
    let toCurrency: String
    let predictedFees: [PredictedFee]
    let exchangeDetails: CurrencyExchangeDetails
    let totalFee: Decimal
    let totalAmountInDestinationCurrency: Decimal
    
    let bestTimeToTransfer: BestTimeToTransfer
    
    /// Returns a concise, readable summary of the fee prediction
    func summary() -> String {
        return """
        Total Fees: \(fromCurrency) \(totalFee)
        Current Exchange Rate: 
        1 \(fromCurrency) = \(exchangeDetails.exchangeRate) \(toCurrency)

        \(bestTimeToTransfer.summary())
        """
    }
    
    static func example() -> InternationalTransferFeePrediction {
         return InternationalTransferFeePrediction(
             transferAmount: 1000.00,
             fromCurrency: "USD",
             toCurrency: "EUR",
             predictedFees: [
                 PredictedFee(
                     id: UUID(),
                     type: .fixed,
                     amount: 15.00,
                     currency: "USD",
                     description: "Fixed processing fee"
                 ),
                 PredictedFee(
                     id: UUID(),
                     type: .exchangeRateMarkup,
                     amount: 10.00,
                     currency: "USD",
                     description: "Markup on the exchange rate"
                 )
             ],
             exchangeDetails: CurrencyExchangeDetails(
                 fromCurrency: "USD",
                 toCurrency: "EUR",
                 exchangeRate: 0.90,
                 exchangeRateMarkup: 0.01
             ),
             totalFee: 25.00,
             totalAmountInDestinationCurrency: 880.00,
             bestTimeToTransfer: BestTimeToTransfer(
                 dates: [Date(timeIntervalSinceNow: 3600 * 24)])
         )
     }
}

struct BestTimeToTransfer: Codable {
    let dates: [Date]

    /// Formats the dates into a readable list.
    func summary() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let formattedDates = dates.map { formatter.string(from: $0) }
        return "Best Dates to Transfer:\n" + formattedDates.joined(separator: "\n")
    }
}
