//
//  ChatLogView.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/2.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

class ChatLogViewModel: ObservableObject{
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
    }
    
    func handleSend(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid
        else {return}
        
        guard let toId = chatUser?.uid else {return}
        
        let document =  FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
        let messageData = ["fromId": fromId, "toId": toId, "text": self.chatText, "timestamp": Timestamp()] as [String: Any]
        
        document.setData(messageData){
            error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            self.chatText = ""
        }
    
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
        
        recipientMessageDocument.setData(messageData){
            error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
        }
        
    }
    
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }

    
    @ObservedObject var vm:  ChatLogViewModel
    
    var body: some View {
            ZStack{
            messageView
            Text(vm.errorMessage)
                
            
        }
        
        
        .navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messageView: some View{
        VStack{
            if #available(iOS 15.0, *){
                ScrollView{
                    ForEach(0..<20){num in
                        HStack{
                            Spacer()
                            HStack{
                                Text("fake message")
                                    .foregroundColor(.white)
                                    
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    HStack{
                        Spacer()
                    }
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                .safeAreaInset(edge: .bottom){
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            }else{
                
            }
        }
        
    }
    
    private var chatBottomBar: some View{
        HStack(spacing: 16){
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            
            ZStack{
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            Button{
                vm.handleSend()
            }label:{
                Text("send")
                    .foregroundColor(.white)
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

private struct DescriptionPlaceholder: View{
    var body: some View{
        HStack{
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainMessageView()
       
    }
}
