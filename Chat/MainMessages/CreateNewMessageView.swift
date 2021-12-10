//
//  CreateNewMessageView.swift
//  Chat
//
//  Created by Darrien Huntley on 12/9/21.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMessgae = " "

    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore
            .collection("users")
            .getDocuments { documentsSnapshot , error in
                if let error = error {
                    self.errorMessgae = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    
                    // Filter out current user
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        
                        // shows a list of all the users
                        self.users.append(.init(data: data))
                    }
                    
                })
              //  self.errorMessgae = "Fetched users successfully"
            }
    }
}

struct CreateNewMessageView: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessgae)
                ForEach(vm.users) { user in
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        
                        didSelectNewUser(user)
                    }) {
                        HStack {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable( )
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                            .stroke(Color(.label), lineWidth: 2)
                                )
                            Text(user.email)
                                .foregroundColor(Color(.label ))
                            
                            Spacer()
                        }.padding(.horizontal)
                       
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
            
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
 //       CreateNewMessageView(didSelectNewUser: <#(ChatUser) -> ()#>)
       MainMessagesView()
    }
}
