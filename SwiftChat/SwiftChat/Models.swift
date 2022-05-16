//
//  Models.swift
//  SwiftChat
//
//  Created by Vong Nyuksoon on 15/05/2022.
//

import Foundation

struct SubmittedChatMessage: Encodable {
    let message: String
    let userId: String
    let username: String
}

struct ReceivingChatMessage: Decodable, Identifiable {
    let date: Date
    let id: String
    let message: String
    let userId: String
    let username: String
}

struct UserInfo: Identifiable {
    let id: String
    let username: String
}
