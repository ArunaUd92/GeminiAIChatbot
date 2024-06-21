//
//  ChatBubble.swift
//  GeminiAIChatbot
//
//  Created by Aruna Udayanga on 12/06/2024.
//

import SwiftUI

struct ChatBubbleShape: Shape {
    enum Direction {
        case left
        case right
    }
    
    let direction: Direction
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight, direction == .left ? .bottomRight : .bottomLeft],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}

struct ChatBubble<Content>: View where Content: View {
    let direction: ChatBubbleShape.Direction
    let content: () -> Content
    
    init(direction: ChatBubbleShape.Direction, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.direction = direction
    }
    
    var body: some View {
        HStack {
            if direction == .right {
                Spacer()
            }
            content()
                .padding(.all, 10)
                .background(direction == .left ? Color.green : Color.blue)
                .foregroundColor(direction == .left ? Color.white : Color.white)
                .clipShape(ChatBubbleShape(direction: direction))
            if direction == .left {
                Spacer()
            }
        }.padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 20)
         .padding((direction == .right) ? .leading : .trailing, 30)
    }
}

