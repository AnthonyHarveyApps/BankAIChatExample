//
//  ChatViewModel.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    // MARK: - Dependencies
    private let apiManager: APIManagerProtocol
    
    // MARK: - Published Properties
    @Published var messages: [Message] = [
        Message(content: "Hello,\n\nIf you need any help just shout.\n\nBtw I'm O-AI.", isUser: false, timestamp: Date())
    ]
    @Published var failedMessageIDs: [UUID] = []
    @Published var newMessage: String = ""
    @Published var transactionsToChooseFrom: [(line: String, transaction: BankTransaction)] = []
    
    // MARK: - State Properties
    private(set) var awaitingTheChoosingOfATransaction: Bool = false
    
    // MARK: - Initialization
    init(apiManager: APIManagerProtocol = APIManager.shared) {
        self.apiManager = apiManager
    }
    
    // MARK: - Message Handling
    func sendMessage(userMessage: Message, isRetry: Bool = false) async {
        guard !userMessage.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        if !isRetry {
            messages.append(userMessage)
        }
        
        do {
            try await handleMessageResponse(for: userMessage, isRetry: isRetry)
            failedMessageIDs.removeAll(where: { $0 == userMessage.id })
        } catch {
            handleMessageError(for: userMessage)
        }
        
        if !isRetry {
            newMessage = ""
        }
    }
    
    private func handleMessageResponse(for message: Message, isRetry: Bool) async throws {
        if isJustThanking(newMessage: message.content) {
            sendBotResponse(content: "You are welcome. Let me know if you have any additional questions")
            return
        }
        
        if awaitingTheChoosingOfATransaction {
            try await handleTransactionChoice(message: message)
            return
        }
        
        if containsTransactionPhrase(newMessage: message.content) {
            try await handleTransactionRequest(message: message, isRetry: isRetry)
            return
        }
        
        if containsTransferInquiryPhrase(newMessage: message.content) {
            try await handleTransferInquiry(message: message, isRetry: isRetry)
            return
        }
        
        handleGenericMessage(message: message, isRetry: isRetry)
    }
    
    private func handleMessageError(for message: Message) {
        failedMessageIDs.append(message.id)
        sendBotResponse(content: "Sorry, I couldn't process your request at this time. Please try again later.")
    }
    
    // MARK: - Specific Message Handlers
    private func handleTransactionChoice(message: Message) async throws {
        if let closest = findClosestMatch(from: transactionsToChooseFrom.map(\.line), to: message.content),
           let transaction = transactionsToChooseFrom.first(where: { $0.line == closest })?.transaction {
            sendBotResponse(content: "Here are the details:\n\n\(transaction.summary())")
            awaitingTheChoosingOfATransaction = false
        }
    }
    
    private func handleTransactionRequest(message: Message, isRetry: Bool) async throws {
        if message.content.contains("fail") && !isRetry {
            throw URLError(.badURL)
        }
        
        let transactions = try await apiManager.getBankTransactions()
        
        if !transactions.isEmpty {
            let summary = transactions.transactionListSummary()
            transactionsToChooseFrom = summary.details
            
            sendBotResponse(content: "Here are your recent transactions:\n\n\(summary.summary)")
            try? await Task.sleep(nanoseconds: 500_000_000) // Half second between messages
            sendBotResponse(content: "Which transaction do you want details on?")
            awaitingTheChoosingOfATransaction = true
        } else {
            sendBotResponse(content: "We did not find any transactions in your history.")
        }
    }
    
    private func handleTransferInquiry(message: Message, isRetry: Bool) async throws {
        if message.content.contains("fail") && !isRetry {
            throw URLError(.badURL)
        }
        
        let predictedFee = try await apiManager.getPredictedFee(from: "USD", to: "PHP")
        sendBotResponse(content: "Here is some info that may help:\n\n\(predictedFee.summary())")
    }
    
    private func handleGenericMessage(message: Message, isRetry: Bool) {
        if message.content.contains("fail") && !isRetry {
            failedMessageIDs.append(message.id)
        }
        sendBotResponse(content: "In a real app this would be sent to an LLM for processing. Try asking for 'status of transaction' or 'transfer rate'")
    }
    
    // MARK: - Helper Methods
    private func sendBotResponse(content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let botMessage = Message(content: content, isUser: false, timestamp: Date())
        messages.append(botMessage)
    }
    
    func containsTransactionPhrase(newMessage: String) -> Bool {
        containsPhrase(newMessage, in: transactionPhrases)
    }
    
    func containsTransferInquiryPhrase(newMessage: String) -> Bool {
        containsPhrase(newMessage, in: transferInquiryPhrases)
    }
    
    func isJustThanking(newMessage: String) -> Bool {
        let normalizedMessage = newMessage.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return thankYouPhrases.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .contains(normalizedMessage)
    }
    
    private func containsPhrase(_ message: String, in phrases: [String]) -> Bool {
        let normalizedMessage = message.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return phrases.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .contains { normalizedMessage.contains($0) }
    }
    
    // MARK: - String Matching
    func findClosestMatch(from array: [String], to target: String) -> String? {
        let targetWords = target.lowercased().split(separator: " ").map(String.init)
        
        let scores = array.map { element -> (String, Int) in
            (element, calculateMatchScore(element, targetWords: targetWords, target: target))
        }
        
        return scores.max(by: { $0.1 < $1.1 })?.0 ?? array.first(where: { $0.contains(target) }) ?? array.first
    }
    
    private func calculateMatchScore(_ element: String, targetWords: [String], target: String) -> Int {
        let elementWords = element.lowercased().split(separator: " ").map(String.init)
        var score = targetWords.filter { elementWords.contains($0) }.count
        
        // Match numbers and dates
        score += matchPattern(in: element, target: target, pattern: "\\d+(\\.\\d+)?", weight: 2)
        score += matchPattern(in: element, target: target, pattern: "\\d{2}-\\d{2}-\\d{2}", weight: 3)
        
        return score
    }
    
    private func matchPattern(in element: String, target: String, pattern: String, weight: Int) -> Int {
        let regex = try! NSRegularExpression(pattern: pattern)
        let elementMatches = extractMatches(from: element, using: regex)
        let targetMatches = extractMatches(from: target, using: regex)
        
        return targetMatches.filter { elementMatches.contains($0) }.count * weight
    }
    
    private func extractMatches(from text: String, using regex: NSRegularExpression) -> [String] {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, range: range)
        return matches.map { String(text[Range($0.range, in: text)!]) }
    }
}
