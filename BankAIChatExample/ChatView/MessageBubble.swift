//
//  MessageBubble.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 10) {
            HStack(alignment: .bottom, spacing: 8) {
                if !message.isUser {
                    Image(.bankAIIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? purpleBackgroundGradient : whiteBackgroundGradient)
                    .foregroundColor(message.isUser ? .white : .black)
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 14,
                        bottomLeading: 14,
                        bottomTrailing: message.isUser ? 2 : 14,
                        topTrailing: message.isUser ? 14 : 2),
                        style: .continuous))
                if message.isUser {
                    AsyncImage(url: userimageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                }
            }
            .padding(.horizontal, 4)
            .frame(
                width: screenWidth - 90,
                alignment: message.isUser ? .trailing : .leading
            )
            Text(formatTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter.string(from: date).lowercased()
    }
}

#Preview {
    MessageBubble(message: Message(content: "Hello,\n\nIf you need any help just shout.\n\nBtw I'm O-AI.", isUser: false, timestamp: Date()))
}
