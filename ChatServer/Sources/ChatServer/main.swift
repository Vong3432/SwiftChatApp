import Vapor

var env = try Environment.detect()
let app = Application(env)

// The Swift defer statement is useful for cases where we need something done — no matter what — before exiting the scope.
// Register a defer and call .shutdown() which will perform any cleanup when exiting the program.
defer {
    app.shutdown()
}

var clientConnections = Set<WebSocket>()

app.webSocket("chat") { req, client in
    clientConnections.insert(client)
    
    client.onClose.whenComplete { _ in
        clientConnections.remove(client)
    }
    
    client.onText { _, text in
        do {
            guard let data = text.data(using: .utf8) else {
                return
            }
            
            let incomingMessage = try JSONDecoder().decode(SubmittedChatMessage.self, from: data)
            let outgoingMessage = ReceivingChatMessage(
                message: incomingMessage.message,
                userId: incomingMessage.userId,
                username: incomingMessage.username
            )
            let json = try JSONEncoder().encode(outgoingMessage)
            
            guard let jsonString = String(data: json, encoding: .utf8) else {
                return
            }
            
            for connection in clientConnections {
                connection.send(jsonString)
            }
        }
        catch {
            print(error) // 6
        }
    }
}

try app.run()


extension WebSocket: Hashable {
    public static func == (lhs: WebSocket, rhs: WebSocket) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
