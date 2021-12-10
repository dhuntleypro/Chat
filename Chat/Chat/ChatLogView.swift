//
//  ChatLogView.swift
//  Chat
//
//  Created by Darrien Huntley on 12/10/21.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    let chatUser: ChatUser?
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
    }
    
    func handleSend() {
        
        print(chatText)
        
        // from id ...
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        // to id ...
        guard let toId = chatUser?.uid else { return }
        
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        //
        let messageDate = [
            "fromId" : fromId,
            "toId" : toId,
            "text" : self.chatText,
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
        }
        
        // give the revicing user
        let recipentMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
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
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    
                    HStack {
                        Text("Fake message for now")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                
                
            }
            //  .frame(maxWidth: .infinity)
            
            HStack{Spacer()}
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


struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            //   ChatLogView(chatUser: nil)
            
//            ChatLogView(chatUser: .init(data: [
//                // set uid to one of the uid in firebase
//                "uid" : "3VmfvAz5Z1NLfChdnQhbqrrVu9J3",
//                "email" : "fake@gmail.com"
//
//            ]))
            MainMessagesView()
        }
    }
}
