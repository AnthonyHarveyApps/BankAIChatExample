//
//  Message.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import Foundation
import SwiftData

@Model
class Message: Identifiable, Equatable {
    @Attribute(.unique) var id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date

    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

extension Array where Element == Message {
    func generateTranscript() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return self.map { message in
            let sender = message.isUser ? "User" : "BankChatAI"
            let timestamp = dateFormatter.string(from: message.timestamp)
            return "[\(timestamp)] \(sender): \(message.content)"
        }.joined(separator: "\n")
    }
}
