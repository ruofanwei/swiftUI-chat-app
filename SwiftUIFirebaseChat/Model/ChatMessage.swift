//
//  ChatMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/2.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
