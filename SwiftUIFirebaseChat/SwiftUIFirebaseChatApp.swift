//
//  SwiftUIFirebaseChatApp.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/1.
//

import SwiftUI

@main
struct SwiftUIFirebaseChatApp: App {
    var body: some Scene {
        WindowGroup {
            MainMessagesView()
        }
    }
}

struct Previews_SwiftUIFirebaseChatApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
