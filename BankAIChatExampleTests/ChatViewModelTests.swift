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
        XCTAssertEqual(viewModel.messages.count, 4, "Expected 4 messages: initial message, user message, and 2 bot responses.")
        XCTAssertTrue(viewModel.messages[1].isUser, "Second message should be from the user.")
        XCTAssertFalse(viewModel.messages[2].isUser, "Third message should be a bot response.")
        XCTAssertTrue(viewModel.messages[2].content.contains("Here are your recent transactions"), "Bot response should include 'Here are your recent transactions' text.")
        XCTAssertTrue(viewModel.awaitingTheChoosingOfATransaction, "ViewModel should set awaitingTheChoosingOfATransaction to true after fetching transactions.")
    }
    
    func testHandleTransactionRequestFailure() async throws {
        // Given
        mockAPI.shouldThrowError = true
        let message = Message(content: "show me my transactions", isUser: true, timestamp: Date())
        
        // When
        await viewModel.sendMessage(userMessage: message)
        
        // Then
        XCTAssertEqual(viewModel.messages.count, 3, "Expected 3 messages: initial message, user message, and an error bot response.")
        XCTAssertTrue(viewModel.messages[1].isUser, "Second message should be from the user.")
        XCTAssertFalse(viewModel.messages[2].isUser, "Third message should be a bot response.")
        XCTAssertTrue(viewModel.messages[2].content.contains("Sorry, I couldn't process your request"), "Bot response should include an error message indicating failure to process the request.")
        XCTAssertFalse(viewModel.awaitingTheChoosingOfATransaction, "ViewModel should not set awaitingTheChoosingOfATransaction to true when API call fails.")
    }
    
    func testHandleTransferInquirySuccess() async throws {
        // Given
        let prediction = InternationalTransferFeePrediction.example()
        mockAPI.mockFeePrediction = prediction
        let message = Message(content: "what's the transfer rate", isUser: true, timestamp: Date())
        
        // When
        await viewModel.sendMessage(userMessage: message)
        
        // Then
        XCTAssertEqual(viewModel.messages.count, 3, "Expected 3 messages: initial message, user message, and a bot response.")
        XCTAssertTrue(viewModel.messages[1].isUser, "Second message should be from the user.")
        XCTAssertFalse(viewModel.messages[2].isUser, "Third message should be a bot response.")
        XCTAssertTrue(viewModel.messages[2].content.contains("Here is some info"), "Bot response should include 'Here is some info' text.")
    }
}
