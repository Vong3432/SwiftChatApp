//
//  ChatScreen.swift
//  SwiftChat
//
//  Created by Vong Nyuksoon on 15/05/2022.
//

import SwiftUI

struct ChatScreen: View {
    @StateObject private var vm = ChatScreenViewModel()
    @State private var message = ""
    @State private var username = ""
    
    private var disableTextInput: Bool {
        username.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack {
            TextField("My username", text: $username)
                .padding(10)
                .cornerRadius(5)
            
            // Chat history.
            ScrollView {
                // Autoscrolling
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 8) {
                        ForEach(vm.messages) { message in
                            if vm.isSelf(message.userId) {
                                VStack(alignment: .trailing) {
                                    Text("ME")
                                    Text(message.message)
                                        .id(message.id)
                                        .padding(10)
                                        .frame(maxWidth: 300, alignment: .leading)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            } else {
                                VStack(alignment: .leading) {
                                    Text(message.username.capitalized)
                                    Text(message.message)
                                        .id(message.id)
                                        .padding(10)
                                        .frame(maxWidth: 300, alignment: .leading)
                                        .background(Color.secondary.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: vm.messages.count) { _ in
                        scrollToLastMessage(proxy: proxy)
                    }
                }
            }
            
            // Message field.
            HStack {
                TextField("Message", text: $message)
                    .onSubmit(onCommit)
                    .padding(10)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(5)
                
                Button(action: onCommit) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.system(size: 20))
                }
                .padding()
                .disabled(message.isEmpty) // 4
            }
            .disabled(disableTextInput)
            .padding()
        }
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = vm.messages.last { // 4
            withAnimation(.easeOut(duration: 0.4)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom) // 5
            }
        }
    }
    
    private func onAppear() {
        vm.connect()
    }
    
    private func onDisappear() {
        vm.disconnect()
    }
    
    private func onCommit() {
        if !message.isEmpty {
            vm.send(text: message, username: username)
            message = ""
        }
    }
}

struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreen()
    }
}
