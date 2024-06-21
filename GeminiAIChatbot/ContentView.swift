//
//  ContentView.swift
//  GeminiAIChatbot
//
//  Created by Aruna Udayanga on 12/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var textInput = ""
    @State private var logoAnimating = false
    @State private var animationTimer: Timer?
    
    @ObservedObject private var chatService = ChatService()
    
    var body: some View {
        VStack {
            // MARK: Animating logo
            Image("gemini-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .opacity(logoAnimating ? 0.5 : 1)
                .animation(.easeInOut, value: logoAnimating)
            
            // MARK: Chat message list
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(chatService.messages) { chatMessage in
                        chatMessageView(chatMessage)
                    }
                }
                .onChange(of: chatService.messages) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: chatService.loadingResponse) { _, newValue in
                    handleLoadingAnimation(newValue)
                }
            }
            
            // MARK: Input fields
            HStack {
                TextField("Enter a message...", text: $textInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                    
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
    
    // MARK: Chat message view
    @ViewBuilder private func chatMessageView(_ message: ChatMessage) -> some View {
        ChatBubble(direction: message.role == .model ? .left : .right) {
            Text(message.message)
                .font(.title3)
                .padding(12)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    // MARK: Send message
    private func sendMessage() {
        chatService.sendMessage(textInput)
        textInput = ""
    }
    
    // MARK: Handle scrolling
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let recentMessage = chatService.messages.last else { return }
        DispatchQueue.main.async {
            withAnimation {
                proxy.scrollTo(recentMessage.id, anchor: .bottom)
            }
        }
    }
    
    // MARK: Handle loading animation
    private func handleLoadingAnimation(_ isLoading: Bool) {
        if isLoading {
            startLoadingAnimation()
        } else {
            stopLoadingAnimation()
        }
    }
    
    // MARK: Response loading animation
    private func startLoadingAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            logoAnimating.toggle()
        }
    }
    
    private func stopLoadingAnimation() {
        logoAnimating = false
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview {
    ContentView()
}
