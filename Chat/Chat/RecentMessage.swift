//
//  RecentMessage.swift
//  Chat
//
//  Created by Darrien Huntley on 12/11/21.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
  //  var id: String { documentId }
    @DocumentID var id: String?
    
//    let documentId: String
    let text, fromId, toId , email, profileImageUrl: String
    let timestamp : Date
   // let timestamp : Timestamp
    
//    init(documentId: String, data: [String: Any]) {
//        self.documentId = documentId
//        self.text = data[FirebaseConstants.text] as? String ?? ""
//        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
//        self.toId = data[FirebaseConstants.toId] as? String ?? ""
//        self.email = data[FirebaseConstants.email] as? String ?? ""
//        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
//    //    self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp ?? Timestamp(date: Date())
//    }
}
