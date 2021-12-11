//
//  MainMessagesView.swift
//  Chat
//
//  Created by Darrien Huntley on 12/9/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift


class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser : ChatUser?
    
    // Sign Out [handle sign out]
    @Published var isUserCurrentlyLoggedOut = false
    
    
    init() {
        // show login screen if no user
        
        DispatchQueue.main.async { // helps with full screen bug
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        
        fetchCurrentUser()
        
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recent_messages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    //   if change.type == .added {
                    let docId = change.document.documentID
                    
                    // Pulls the most recent message : edited / created
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    // With firebase firestore swift no need to init
                    do {
                       if let rm = try change.document.data(as: RecentMessage.self) {
                            self.recentMessages.insert(rm, at: 0)
                        }
                    } catch {
                        print(error)
                    }
                     
                    
                   
                    // old way without  firebase firestore swift
                    //self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                    //    }
                })
            }
    }
    
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        // self.errorMessage = "\(uid)"
        
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "build to fetch current user \(error)"
                    
                    print("Fail to fetch current user", error)
                    return
                }
                //  self.errorMessage = "\(uid)"
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "No Data found"
                    return
                }
                
                self.chatUser = .init(data: data)
                
                // Shows all the data under user
                // self.errorMessage = "Data: \(data.description)"
                
                
                
            }
    }
    
    func handleSignOut() {
        // Change state
        isUserCurrentlyLoggedOut.toggle()
        
        // Log out of firebase
        try? FirebaseManager.shared.auth.signOut()
    }
}




struct MainMessagesView: View {
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    // Log out action sheet...
    @State var shouldShowLogOutOptions = false
    
    // track selected user...
    @State var chatUser: ChatUser?
    
    @State var shouldNavigateToChatLogView = false
    
    var body: some View {
        NavigationView {
            VStack {
                //   Text("User: \(vm.chatUser?.uid ?? "")")
                
                // custom nav bar
                customNavBar
                messageView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
                
            }
            .overlay( newMessageButton , alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    
    
    
    
    
    private var customNavBar: some View {
        
        
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
            //    .frame(width: 44, height: 44)
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label), lineWidth: 1)
                         
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading , spacing: 4) {
                // Text("\(vm.chatUser?.email ?? "" )")
                
                // Removes @.... from email to set username
                ZStack {
                    if ((vm.chatUser?.email.contains("@gmail.com")) != nil) {
                        Text("\(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com" , with: "") ?? "ha" )")
                            .font(.system(size: 24, weight: .bold))
                    }
                    
                    else if ((vm.chatUser?.email.contains("@gmail.com")) != nil) {
                        Text("\(vm.chatUser?.email.replacingOccurrences(of: "@yahoo.com" , with: "") ?? "ha" )")
                            .font(.system(size: 24, weight: .bold))
                    }
                    
                    else if ((vm.chatUser?.email.contains("@gmail.com")) != nil) {
                        Text("\(vm.chatUser?.email.replacingOccurrences(of: "@icloud.com" , with: "") ?? "ha" )")
                            .font(.system(size: 24, weight: .bold))
                    }
                }
                
                
                // OR
                
                
                //                    let gmailUserName = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com" , with: "") ?? ""
                //                    let yahooUserName = vm.chatUser?.email.replacingOccurrences(of: "@yahoo.com" , with: "") ?? ""
                //
                //                    let icloudUserName = vm.chatUser?.email.replacingOccurrences(of: "@icloud.com" , with: "") ?? ""
                //
                //                    // Enter other email types....
                //                    ZStack {
                //                        Text("\(gmailUserName == "" ? "" : gmailUserName ) ")
                //                        Text("\(yahooUserName == "" ? "" : yahooUserName ) ")
                //                        Text("\(icloudUserName == "" ? "" : icloudUserName ) ")
                //                    }
                //                     .font(.system(size: 24, weight: .bold))
                
                
                
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                    
                }
            }
            
            Spacer()
            
            Button(action: {
                shouldShowLogOutOptions.toggle()
                
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
                }
            }
            .padding()
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"),
                      message: Text("What do you want to do?"),
                      buttons: [
                        .destructive(Text("Sign Out"),
                                     action: {
                                         print("handle sign out")
                                         vm.handleSignOut()
                                         
                                         
                                     }),
                        .cancel()
                      ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                LoginView(didCompleteLoginProcess: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                })
            }
        }
  
        
        
        
  //  }
    
    
    private var messageView : some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    NavigationLink(destination: Text("destination")) {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label) , lineWidth:  1)
                                )
                                .shadow(radius: 5)
                            VStack(alignment: .leading, spacing : 8) {
                                Text(recentMessage.email)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text(recentMessage.text)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            Text(recentMessage.timestamp.description)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    // New Message Button
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button(action: {
            shouldShowNewMessageScreen.toggle()
        }) {
            
            Text("+ New Message")
                .font(.system(size: 16 , weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView(didSelectNewUser: { user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
    
}



struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
          //  .preferredColorScheme(.dark)
        
     //   MainMessagesView()
           
    }
}
