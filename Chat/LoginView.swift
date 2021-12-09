//
//  ContentView.swift
//  Chat
//
//  Created by Darrien Huntley on 12/9/21.
//

import SwiftUI
import Firebase
// import FirebaseFirestore


struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var isAdmin = false

    // Error Message
    @State private  var loginStatusMessage = ""
    
    // Image Picker
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16){
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button(action: {
                            shouldShowImagePicker.toggle()
                        }) {
                            VStack {
                                //
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                    
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                    // Color changes based on light | Dark mode
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color.black, lineWidth: 3)
                            )
                        }
                        
                    }
                   
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                          
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                 

                    
                    Button(action: {
                        handleAction()
                    }) {
                        HStack {
                            Spacer()
                            
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical,10)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Spacer()
                        }
                        .background(Color.blue)
                    }
                    
                    // Show error [ firebase ]
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                            .ignoresSafeArea()
            )

        }
        // Helps with firebase errors [add to nav view]
        .navigationViewStyle(StackNavigationViewStyle())
    
        // Image Picker
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    // [ firebase ]
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    // [ firebase - login user ]
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {  result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
        
        }
        
    }
    
    // [ firebase - create user ]
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
        
    }
    
    private func persistImageToStorage() {
     //   let filename = UUID().uuidString
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
   
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to storage: \(err)"
                return
            }
            
            ref.downloadURL { url , err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrive download url: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url :  \(url?.absoluteString ?? "")"
                
                // Get url of image
                print(url?.absoluteString ?? self.loginStatusMessage)
                
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
        
        
    }
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["email" : self.email ,
                        "uid" : uid ,
                        "profileImageUrl" : imageProfileUrl.absoluteString,
                        "isAdmin" : self.isAdmin
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                print("Success")
                self.didCompleteLoginProcess()
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {
            
        })
    }
}
