//
//  ChatMessage.swift
//  Chat
//
//  Created by Darrien Huntley on 12/11/21.
//

import SwiftUI
// import firebase firstore swift... recent message setup
struct ChatMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    
    
    init(documentId: String ,  data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
    
}
