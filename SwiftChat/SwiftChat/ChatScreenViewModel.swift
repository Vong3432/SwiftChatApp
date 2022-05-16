//
//  ChatScreenViewModel.swift
//  SwiftChat
//
//  Created by Vong Nyuksoon on 15/05/2022.
//

import Foundation

/// Learn from https://frzi.medium.com/a-simple-chat-app-with-swiftui-and-websockets-or-swift-in-the-back-swift-in-the-front-78b34c3dc912
final class ChatScreenViewModel: ObservableObject {
    
    private var websocketTask: URLSessionWebSocketTask?
    let uid = UUID().uuidString
    
    @Published private(set) var messages: [ReceivingChatMessage] = [
//        ReceivingChatMessage(date: .now, id: "123", message: "asd", userId: "213", username: "john")
    ]
    
    func connect() {
        let url = URL(string: "ws://127.0.0.1:8080/chat")!
        websocketTask = URLSession.shared.webSocketTask(with: url)
        websocketTask?.receive(completionHandler: onReceive)
        websocketTask?.resume()
    }
    
    func disconnect() {
        websocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    func send(text: String, username: String) {
        let message = SubmittedChatMessage(message: text, userId: uid, username: username)
        guard let json = try? JSONEncoder().encode(message),
              let jsonString = String(data: json, encoding: .utf8)
        else {
            return
        }
        
        websocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("Error sending message", error)
            }
        }
    }
    
    func isSelf(_ id: String) -> Bool {
        id == uid
    }
    
    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        // It is because .receive will only listen for once, hence we have to bind it again to listen next incoming message in this function
        websocketTask?.receive(completionHandler: onReceive)
        
        switch incoming {
        case .success(let msg):
            onMessage(message: msg)
        case .failure(let err):
            print("Error \(err)")
        }
    }
             
    private func onMessage(message: URLSessionWebSocketTask.Message) {
        if case .string(let text) = message {
            guard let data = text.data(using: .utf8),
                    let chatMessage = try? JSONDecoder().decode(ReceivingChatMessage.self, from: data)
            else {
                return
            }

            // because URLSessionWebSocketTask can call the receive handler on a different thread,
            // hence we have to ensure we update UI in main thread
            DispatchQueue.main.async {
                self.messages.append(chatMessage)
            }
        }
    }
    
    deinit { // 9
        disconnect()
    }
}
