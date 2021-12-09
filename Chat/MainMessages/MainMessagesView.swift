//
//  MainMessagesView.swift
//  Chat
//
//  Created by Darrien Huntley on 12/9/21.
//

import SwiftUI
import SDWebImageSwiftUI




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
    
    @State var shouldShowLogOutOptions = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("User: \(vm.chatUser?.uid ?? "")")
                // custom nav bar
                customNavBar
                messageView
                
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
                .frame(width: 44, height: 44)
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label), lineWidth: 1)
                
                )
                .shadow(radius: 5)
            
//            Image(systemName: "person.fill")
//                .font(.system(size: 34, weight: .heavy))
            
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
                        .foregroundColor(Color(.lightGray))
                }
            }
            
            Spacer()
            
            Button(action: {
                shouldShowLogOutOptions.toggle()
                
            }) {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
            }
        }
        
    }
 
    
    private var messageView : some View {
        ScrollView {
            ForEach(0..<10 , id: \.self ) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label) , lineWidth:  1)
                            )
                        VStack(alignment: .leading) {
                            Text("Username")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message sent to user")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.lightGray))
                        }
                        
                        Spacer()
                        
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    
    private var newMessageButton: some View {
        Button(action: {}) {
            
            Text("+ New Message")
                .font(.system(size: 16 , weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
            
            
            
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
    }
    
    
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        
        MainMessagesView()
    }
}
