//
//  MainView.swift
//  BankAIChatExample
//
//  Created by Anthony Harvey on 12/13/24.
//

import SwiftUI

import SwiftUI

struct MainView: View {
    private enum Constants {
        static let navigationTitle = "Bank Chat AI Example"
        static let buttonImageName = "message.fill"
        static let buttonFontSize: CGFloat = 24
        static let buttonForegroundColor: Color = .white
        static let buttonBackgroundColor: Color = .purple
        static let buttonWidth: CGFloat = 60
        static let buttonHeight: CGFloat = 60
        static let buttonShadowRadius: CGFloat = 4
        static let buttonPadding: CGFloat = 24
    }
    
    @State private var showingChatView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    chatButton
                }
            }
            .navigationTitle(Constants.navigationTitle)
        }
        .fullScreenCover(isPresented: $showingChatView) {
            ChatView(showingChat: $showingChatView)
        }
    }
    
    private var chatButton: some View {
        HStack {
            Spacer()
            Button {
                showingChatView = true
            } label: {
                Image(systemName: Constants.buttonImageName)
                    .font(.system(size: Constants.buttonFontSize))
                    .foregroundColor(Constants.buttonForegroundColor)
                    .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
                    .background(Constants.buttonBackgroundColor)
                    .clipShape(Circle())
                    .shadow(radius: Constants.buttonShadowRadius)
            }
            .padding(Constants.buttonPadding)
        }
    }
}


#Preview {
    MainView()
}
