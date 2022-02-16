import SwiftUI

struct ContentView: View {
    
    @State private var chatMessage = ""
    @State private var messages: [String] = []
    @State private var webScoketTask: URLSessionWebSocketTask!
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter a message", text: $chatMessage)
                    .padding([.leading, .top, .bottom])
                Button("Send", action: {sendMessageTapped()})
                    .padding(.trailing)
            }
            
            List(messages, id:\.self) { message in
                Text(message)
            }
            .onAppear(perform: setupSocket)
            .onDisappear(perform: closeSocket)
        }
    }
    
    func setupSocket() {
        let webscoketURL = URL(string: "ws://localhost:8080/chat")!
        
        webScoketTask = URLSession.shared.webSocketTask(with: webscoketURL)
        listenForMessage()
        webScoketTask.resume()
    }
    
    func listenForMessage() {
        self.webScoketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self.messages.insert(text, at: 0)
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
                self.listenForMessage()
            }
        }
    }
    
    func closeSocket() {
        webScoketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func sendMessageTapped() {
        let message = URLSessionWebSocketTask.Message.string(self.chatMessage)
        self.webScoketTask.send(message) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

