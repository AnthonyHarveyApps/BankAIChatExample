//
//  APIManager.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import Foundation

protocol APIManagerProtocol {
    func getBankTransactions() async throws -> [BankTransaction]
    func getPredictedFee(from: String, to: String) async throws -> InternationalTransferFeePrediction
}

class APIManager: APIManagerProtocol {
    static let shared = APIManager()

    func getPredictedFee(from: String, to: String) async throws -> InternationalTransferFeePrediction {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Fake wait
        guard let data = feePredictionJSON.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON", code: 1)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(InternationalTransferFeePrediction.self, from: data)
    }
    
    func getBankTransactions() async throws -> [BankTransaction] {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Fake wait
        guard let data = transactionsJSON.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON", code: 2)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601  // Use ISO 8601 decoding for dates.
        return try decoder.decode([BankTransaction].self, from: data)
    }
}

// Add MockAPIManager
class MockAPIManager: APIManagerProtocol {
    var shouldThrowError: Bool = false
    var mockTransactions: [BankTransaction] = []
    var mockFeePrediction: InternationalTransferFeePrediction?
    
    func getBankTransactions() async throws -> [BankTransaction] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1)
        }
        return mockTransactions
    }
    
    func getPredictedFee(from: String, to: String) async throws -> InternationalTransferFeePrediction {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 2)
        }
        return mockFeePrediction ?? InternationalTransferFeePrediction.example()
    }
}
