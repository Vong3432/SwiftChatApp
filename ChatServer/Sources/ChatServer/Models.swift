//
//  File.swift
//  
//
//  Created by Vong Nyuksoon on 15/05/2022.
//

import Foundation

struct SubmittedChatMessage: Decodable {
    let message: String
    let userId: String
    let username: String
}

struct ReceivingChatMessage: Encodable, Identifiable {
    let date = Date()
    let id = UUID()
    let message: String
    let userId: String
    let username: String
}
