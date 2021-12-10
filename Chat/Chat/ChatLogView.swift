//
//  ChatLogView.swift
//  Chat
//
//  Created by Darrien Huntley on 12/10/21.
//

import SwiftUI
import Firebase


struct FirebaseConstants {
    
    static let messages = "messages"
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp" // fix acroos app
}


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
class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    let chatUser: ChatUser?
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    // always listening ......
    private func fetchMessages() {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
        
        // real time listsener ...
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                // real time listsener for new things added...
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID , data: data))
                    }
                    
                })
                
                // change made scroll to bottom...
                DispatchQueue.main.async {
                    self.count += 1
                }
               
                
                /*
                 // real time listsener for everything chaging all messages...
                 querySnapshot?.documents.forEach({ queryDocumentSnapshot in
                 let data = queryDocumentSnapshot.data()
                 let docId = queryDocumentSnapshot.documentID
                 self.chatMessages.append(.init(documentId: docId , data: data))
                 })
                 */
            }
    }
    
    
    func handleSend() {
        
        print(chatText)
        
        // from id ...
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        // to id ...
        guard let toId = chatUser?.uid else { return }
        
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        //
        let messageDate = [
            FirebaseConstants.fromId : fromId,
            FirebaseConstants.toId : toId,
            FirebaseConstants.text : self.chatText,
            "timestamp" : Timestamp()
            
        ] as [String : Any]
        
        // save
        document.setData(messageDate) { error in
            if let error = error {
                self.errorMessage = "Fail to save message into firestore: \(error) "
                return
            }
            print("Sucessfully saved current user sending messages")
            self.chatText = ""
            
            // change made scroll to bottom...
            self.count += 1
        }
        
        // give the revicing user
        let recipentMessageDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()
        
        // save
        recipentMessageDocument.setData(messageDate) { error in
            if let error = error {
                self.errorMessage = "Fail to save message into firestore: \(error) "
                return
            }
            print("Recipent saved message as well")
            
        }
        
       
    }
    
    // tracks when ever there is a change
    @Published var count = 0
}

struct ChatLogView: View {
    let chatUser: ChatUser?
    
    //  @State var chatText = "" [try to avoid states, place in vm]
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    
    //  @ObservedObject var vm = ChatLogViewModel()
    @ObservedObject var vm : ChatLogViewModel
    
    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarItems(trailing: Button(action: {
//            vm.count += 1
//        }) {
//            Text("Count: \(vm.count)")
//        })
    }
    
    static let emptyScrollToString = "Empty"
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack{Spacer()}
                    .id(Self.emptyScrollToString)
                }
                // Everytime the count state changes it will auto scroll to the bottom
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeInOut(duration: 0.05)) {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                }
                
               
            }
            
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(
                    Color(.systemBackground)
                        .ignoresSafeArea()
                )
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24 ))
                .foregroundColor(Color(.darkGray))
            
            TextField("Description", text: $vm.chatText)
            //            ZStack {
            //              //  DesctiptionPlaceholder()
            //                TextEditor(text: $chatText)
            //                    .opacity(vm.chatText.isEmpty ? 0.5 : 1 )
            //
            //
            //            }
            
            Button(action: {
                vm.handleSend()
            }) {
                Text("Send")
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}





struct MessageView: View {
    let message : ChatMessage
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
            } else {
                HStack {
                    
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                }
                
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}



struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
       // NavigationView {
            //   ChatLogView(chatUser: nil)
            
            //            ChatLogView(chatUser: .init(data: [
            //                // set uid to one of the uid in firebase
            //                "uid" : "3VmfvAz5Z1NLfChdnQhbqrrVu9J3",
            //                "email" : "fake@gmail.com"
            //
            //            ]))
            MainMessagesView()
      //  }
    }
}
