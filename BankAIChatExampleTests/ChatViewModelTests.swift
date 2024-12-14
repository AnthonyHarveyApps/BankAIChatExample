//
//  ChatViewModelTests.swift
//  BankAIChatExampleTests
//
//  Created by Anthony Harvey on 12/13/24.
//
//

import XCTest
@testable import BankAIChatExample

@MainActor // Add MainActor attribute to the test class
final class ChatViewModelTests: XCTestCase {
    private var mockAPI: MockAPIManager!
    private var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        mockAPI = MockAPIManager()
        viewModel = ChatViewModel(apiManager: mockAPI)
    }
    
    override func tearDown() {
        mockAPI = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testHandleTransactionRequestSuccess() async throws {
        // Given
        let transaction = BankTransaction.exampleTransaction
        mockAPI.mockTransactions = [transaction]
        let message = Message(content: "show me my transactions", isUser: true, timestamp: Date())
        
        // When
        await viewModel.sendMessage(userMessage: message)
        
        // Then
        XCTAssertEqual(viewModel.messages.count, 4) // Initial + user + 2 bot responses
        XCTAssertTrue(viewModel.messages[1].isUser)
        XCTAssertFalse(viewModel.messages[2].isUser)
        XCTAssertTrue(viewModel.messages[2].content.contains("Here are your recent transactions"))
        XCTAssertTrue(viewModel.awaitingTheChoosingOfATransaction)
    }
    
    func testHandleTransactionRequestFailure() async throws {
        // Given
        mockAPI.shouldThrowError = true
        let message = Message(content: "show me my transactions", isUser: true, timestamp: Date())
        
        // When
        await viewModel.sendMessage(userMessage: message)
        
        // Then
        XCTAssertEqual(viewModel.messages.count, 3) // Initial + user + error message
        XCTAssertTrue(viewModel.messages[1].isUser)
        XCTAssertFalse(viewModel.messages[2].isUser)
        XCTAssertTrue(viewModel.messages[2].content.contains("Sorry, I couldn't process your request"))
        XCTAssertFalse(viewModel.awaitingTheChoosingOfATransaction)
    }
    
    func testHandleTransferInquirySuccess() async throws {
        // Given
        let prediction = InternationalTransferFeePrediction.example()
        mockAPI.mockFeePrediction = prediction
        let message = Message(content: "what's the transfer rate", isUser: true, timestamp: Date())
        
        // When
        await viewModel.sendMessage(userMessage: message)
        
        // Then
        XCTAssertEqual(viewModel.messages.count, 3) // Initial + user + bot response
        XCTAssertTrue(viewModel.messages[1].isUser)
        XCTAssertFalse(viewModel.messages[2].isUser)
        XCTAssertTrue(viewModel.messages[2].content.contains("Here is some info"))
    }
}
