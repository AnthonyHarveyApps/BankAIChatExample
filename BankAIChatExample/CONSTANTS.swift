//
//  CONSTANTS.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import UIKit
import SwiftUI

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let screenSize = UIScreen.main.bounds.size

let userimageURL = URL(string: "https://picsum.photos/200")


let purpleBackgroundGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(hue: 0.76, saturation: 0.7, brightness: 0.9).opacity(0.91),
        .purple.opacity(0.88),
        .purple.opacity(0.98)
    ]),
    startPoint: .bottomLeading,
    endPoint: .trailing
)

let whiteBackgroundGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 0.98, green: 0.98, blue: 0.96).opacity(0.92),
        .white.opacity(0.98)
    ]),
    startPoint: .topLeading,
    endPoint: .trailing
)

let thankYouPhrases = [
    "Thanks",
    "thank you",
    "thank",
    "great thanks",
    "thank you very much",
    "Thanks a lot",
    "Thanks so much",
    "Thank you so much",
    "Many thanks",
    "Thanks tons",
    "Thanks a tons",
    "Much obliged",
    "Cheers",
    "Ta",
    "Thanks a million",
    "Thanks kindly",
    "Appreciate it",
    "Greatly appreciated",
    "Thank you kindly",
    "Big thanks",
    "Grateful",
    "Thankful"
]

let transactionPhrases = [
    "Show me my transactions",
    "I want to see my transactions",
    "Can I view my transactions?",
    "List my transactions",
    "Display my transactions",
    "What are my recent transactions?",
    "Show my account activity",
    "Let me see my transaction history",
    "View my transaction history",
    "Check my transactions",
    "Can you show my transaction list?",
    "I’d like to see my recent purchases",
    "Show me what I’ve spent recently",
    "Can I check my recent payments?",
    "Where can I see my transactions?",
    "Open my transaction history",
    "Can I view my account activity?",
    "What transactions have I made recently?",
    "List my recent account activity",
    "Display my purchase history",
    "Can you pull up my transactions?",
    "How can I see my transactions?",
    "I want to check my account history",
    "Where’s my transaction list?",
    "Show me my spending history",
    "Can I get a list of my payments?",
    "View my banking transactions",
    "Show me what I’ve paid for recently",
    "Let me see my spending activity",
    "status of a transaction",
    "status of transaction",
    "transaction status",
    "dog" // for easy testing
]
#warning("Remove dog for production")

let transferInquiryPhrases = [
    "transfer rate",
    "What is the current transfer rate?",
    "Show me the transfer fees",
    "How much does it cost to send money?",
    "What are the fees for transferring money?",
    "Tell me the exchange rate",
    "What is the conversion rate right now?",
    "How much will it cost to send money internationally?",
    "Can you show me the transfer rates?",
    "What are the charges for sending money abroad?",
    "I want to know the fees for transferring money",
    "When is the best time to send money?",
    "Is now a good time to send money?",
    "Check the best time to transfer funds",
    "What are the current rates for international transfers?",
    "How much does it cost to send money overseas?",
    "What is the rate for sending USD to EUR?",
    "Tell me the transfer fees for sending money",
    "Can I see the international transfer rates?",
    "How can I find out the cost of a transfer?",
    "What’s the fee for sending money to another country?",
    "What is the best time to send money abroad?",
    "Show me the cheapest time to transfer money",
    "What are the fees for an international wire transfer?",
    "What’s the rate for sending money right now?",
    "Can you give me the cost of sending money to another country?",
    "How much does a wire transfer cost?",
    "What’s the transfer fee for today?",
    "when the best time to send a payment to the Philippines",
    "cat" // for easy testing
]
#warning("Remove cat for production")

let feePredictionJSON = """
    {
        "transferAmount": 100.00,
        "fromCurrency": "USD",
        "toCurrency": "PHP",
        "predictedFees": [
            {
                "id": "8BAA0D35-461D-4A62-B9FD-EB762E1C26DF",
                "type": "Fixed Fee",
                "amount": 10.00,
                "currency": "USD",
                "description": "Flat transfer fee"
            },
            {
                "id": "B67F5F82-8386-4EF7-89BC-CF4B7513F6DD",
                "type": "Exchange Rate Markup",
                "amount": 5.00,
                "currency": "USD",
                "description": "Markup due to exchange rate adjustment"
            }
        ],
        "exchangeDetails": {
            "fromCurrency": "USD",
            "toCurrency": "PHP",
            "exchangeRate": 58.31,
            "exchangeRateMarkup": 0.03
        },
        "totalFee": 15.00,
        "totalAmountInDestinationCurrency": 5750.23,
        "bestTimeToTransfer": {
            "dates": [
                "2024-12-15T00:00:00Z",
                "2024-12-20T00:00:00Z",
                "2024-12-25T00:00:00Z"
            ]
        }
    }
    """

let transactionsJSON = """
    [
        {
            "id": "D7CF98E9-70BC-44EE-9E84-8E66FB0E3627",
            "date": "2024-12-13T12:00:00Z",
            "amount": 150.75,
            "currency": "USD",
            "senderAccount": "1234567890",
            "receiverAccount": "0987654321",
            "type": "Transfer",
            "status": "Completed",
            "description": "Transfer to savings account"
        },
        {
            "id": "B2A4E5E9-CC44-4999-B92A-9654C08398C7",
            "date": "2024-12-10T09:30:00Z",
            "amount": 12000.00,
            "currency": "USD",
            "senderAccount": "1234567890",
            "receiverAccount": null,
            "type": "Deposit",
            "status": "Completed",
            "description": "Monthly Salary"
        }
    ]
    """
