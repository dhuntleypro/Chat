//
//  ChatApp.swift
//  Chat
//
//  Created by Darrien Huntley on 12/9/21.
//

import SwiftUI

// command + 1 : shows side menu
// control + command + e : edit all with same name in application



@main
struct ChatApp: App {
    var body: some Scene {
        WindowGroup {
         //   LoginView()
            MainMessagesView()
        }
    }
}
