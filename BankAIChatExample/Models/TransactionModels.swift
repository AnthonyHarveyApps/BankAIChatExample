//
//  TransactionModels.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import Foundation

enum TransactionStatus: String, Codable {
    case pending = "Pending"
    case completed = "Completed"
    case failed = "Failed"
    case cancelled = "Cancelled"
}

enum TransactionType: String, Codable {
    case deposit = "Deposit"
    case withdrawal = "Withdrawal"
    case transfer = "Transfer"
    case payment = "Payment"
}

struct BankTransaction: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Decimal
    let currency: String
    let senderAccount: String
    let receiverAccount: String?
    let type: TransactionType
    let status: TransactionStatus
    let description: String?
    
    /// Returns a readable string representation of the transaction
    func summary() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let dateText = formatter.string(from: date)
        let amountText = "\(currency) \(amount)"
        let receiverText = receiverAccount ?? "N/A"
        let descriptionText = description ?? "No description"
        
        return """
        Transaction Summary:
        - ID: \(id)
        - Date: \(dateText)
        - Amount: \(amountText)
        - Type: \(type.rawValue)
        - Status: \(status.rawValue)
        - Sender Account: \(senderAccount)
        - Receiver Account: \(receiverText)
        - Description: \(descriptionText)
        """
    }
    
    static let exampleTransaction = BankTransaction(
        id: UUID(),
        date: Date(),
        amount: 150.75,
        currency: "USD",
        senderAccount: "1234567890",
        receiverAccount: "0987654321",
        type: .transfer,
        status: .completed,
        description: "Transfer to savings account"
    )
}

// Example Usage

extension Array where Element == BankTransaction {
    /// Returns a human-readable string that lists the transactions by type, amount, and date.
    /// Also provides an array of tuples containing each summary line and its corresponding transaction.
    func transactionListSummary() -> (summary: String, details: [(line: String, transaction: BankTransaction)]) {
        var returnArray: [(line: String, transaction: BankTransaction)] = []
        guard !self.isEmpty else {
            return ("No transactions available.", [])
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        let summaryList = self.map { transaction -> String in
            let dateText = formatter.string(from: transaction.date)
            let amountText = "\(transaction.currency) \(transaction.amount)"
            let summaryLine = "\(transaction.type.rawValue) of \(amountText) on \(dateText)"
            returnArray.append((line: summaryLine, transaction: transaction))
            return summaryLine
        }
        
        let summaryString = summaryList.joined(separator: "\n\n")
        return (summaryString, returnArray)
    }
}

