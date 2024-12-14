//
//  ChatView.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var messageInSwiftData: [Message]
    
    @ObservedObject private var viewModel = ChatViewModel()
    @Binding var showingChat: Bool
    
    private enum Constants {
        enum Text {
            static let title = "Bank Chat AI"
            static let sendTranscription = "Send Transcription"
            static let endChat = "End Chat"
            static let messagePlaceholder = "Type a Message..."
            static let retry = "Retry"
        }
        
        enum Icon {
            static let menu = "ellipsis"
            static let transcription = "doc.text"
            static let power = "power"
            static let sendMessage = "arrow.up.circle.fill"
            static let failedMessage = "x.circle"
        }
    }

    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            messagesScrollView
            Divider()
            chatInputView
        }
        .background(Color(.systemGray6))
        .onChange(of: viewModel.messages) { oldMessages, newMessages in
            if newMessages.count > 1 {
                persistNewMessages()
            }
        }
        .onAppear {
            if messageInSwiftData.count > 1 {
                viewModel.messages = messageInSwiftData
            }
        }
    }
    
    /// Keeps SwiftData up to date with latest messages
    private func persistNewMessages() {
         // Extract existing ids from SwiftData
         let existingIds = Set(messageInSwiftData.map { $0.id })
         
         // Filter externalItems to find names not already in SwiftData
        let messagesToAdd = viewModel.messages.filter { !existingIds.contains($0.id) }
         
         // Insert missing items into SwiftData
         for message in messagesToAdd {
             modelContext.insert(message)
         }
         
         // Save changes
         try? modelContext.save()
     }
    
    // MARK: - Computed Properties
    
    private var headerView: some View {
        HStack(spacing: 12) {
            Image(.bankAIIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(Constants.Text.title)
                .foregroundColor(.white)
                .fontWeight(.semibold)
            
            Spacer()
            
            headerMenu
        }
        .padding()
        .background(purpleBackgroundGradient)
    }
    
    private var headerMenu: some View {
        Menu {
            if viewModel.messages.count > 1 {
                ShareLink(
                    item: "Chat Transcript",
                    subject: Text("Chat Transcript"),
                    message: Text(viewModel.messages.generateTranscript()),
                    preview: SharePreview("Chat Transcript", image: Image(systemName: "square.and.arrow.up"))
                ) {
                    Label(Constants.Text.sendTranscription, systemImage: Constants.Icon.transcription)
                }
            }
            Button(action: {showingChat = false}) {
                Label(Constants.Text.endChat, systemImage: Constants.Icon.power)
            }
        } label: {
            Image(systemName: Constants.Icon.menu)
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
    }
    
    private var messagesScrollView: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        messageRow(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .onChange(of: viewModel.messages) { messages in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private func messageRow(message: Message) -> some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            MessageBubble(message: message)
            if !message.isUser {
                Spacer()
            } else if viewModel.failedMessageIDs.contains(message.id) {
                failedMessageIcon(message: message)
            }
        }
    }
    
    private func failedMessageIcon(message: Message) -> some View {
        Image(systemName: Constants.Icon.failedMessage)
            .foregroundStyle(Color.red)
            .contextMenu {
                Button(action: {
                    Task {
                        await viewModel.sendMessage(userMessage: message, isRetry: true)
                    }
                }) {
                    Text(Constants.Text.retry)
                }
            }
    }
    
    private var chatInputView: some View {
        HStack(spacing: 8) {
            TextField(Constants.Text.messagePlaceholder, text: $viewModel.newMessage)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onSubmit(sendMessage)
            
            sendButton
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.02))
    }
    
    private var sendButton: some View {
        Button(action: sendMessage) {
            Image(systemName: Constants.Icon.sendMessage)
                .foregroundColor(.purple)
                .font(.system(size: 24))
        }
        .disabled(viewModel.newMessage.isEmpty)
        .opacity(viewModel.newMessage.isEmpty ? 0.6 : 1)
    }
    
    // MARK: - Helper Methods
    
    private func sendMessage() {
        Task {
            let newMessage = Message(
                content: viewModel.newMessage,
                isUser: true,
                timestamp: Date()
            )
            await viewModel.sendMessage(userMessage: newMessage)
        }
    }
}

#Preview {
    ChatView(showingChat: .constant(true))
}
