//
//  ChatService.swift
//  GeminiAIChatbot
//
//  Created by Aruna Udayanga on 12/06/2024.
//

import Foundation
import SwiftUI
import Combine
import GoogleGenerativeAI

enum ChatRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID().uuidString
    var role: ChatRole
    var message: String
}

final class ChatService: ObservableObject {
    @Published private(set) var messages = [ChatMessage]()
    @Published private(set) var loadingResponse = false
    
    private var chat: Chat?
    private var cancellables = Set<AnyCancellable>()
    private let apiKey = APIKey.default
    
    func sendMessage(_ message: String) {
        loadingResponse = true
        messages.append(.init(role: .user, message: message))
        
        if chat == nil {
            let history: [ModelContent] = messages.map {
                ModelContent(role: $0.role == .user ? "user" : "model", parts: $0.message)
            }
            chat = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: apiKey).startChat(history: history)
        }
        
        Task {
            do {
                let response = try await chat?.sendMessage(message)
                DispatchQueue.main.async {
                    self.loadingResponse = false
                    if let text = response?.text {
                        self.messages.append(.init(role: .model, message: text))
                    } else {
                        self.messages.append(.init(role: .model, message: "Something went wrong, please try again."))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingResponse = false
                    self.messages.append(.init(role: .model, message: "Something went wrong, please try again."))
                }
            }
        }
    }
}
