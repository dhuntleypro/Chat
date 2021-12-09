//
//  ContentView.swift
//  Chat
//
//  Created by Darrien Huntley on 12/9/21.
//

import SwiftUI
import Firebase


class FirebaseManager: NSObject {
    let auth: Auth
    static let shared = FirebaseManager()
    
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()

        super.init()
    }
}


// When installing firebase select : Firebase auth + Firebase Storage
// Install firestore through cocopods


struct LoginView: View {
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""

    // Error Message
    @State var loginStatusMessage = ""
    
    
    
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
                        Button(action: {}) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
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
    }
    
    // [ firebase ]
    private func handleAction() {
        if isLoginMode {
            print("Should log into Firebase with existing credentials")
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
        
        }
        
    }
    
    // [ firebase - create user ]
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
        }
    }
    
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
