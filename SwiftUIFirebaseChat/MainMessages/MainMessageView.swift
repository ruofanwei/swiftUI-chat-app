//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/1.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct RecentMessage:Identifiable{
    var id: String {documentId}
    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp
    
    init(documentId:String, data: [String: Any]){
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        
        fetchCurrentUser()
        
        fetchRecentMessage()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private func fetchRecentMessage(){
        guard let uid =  FirebaseManager.shared.auth.currentUser?.uid else {
            
            self.errorMessage = "could not find firebase uid"
            return}
        
        FirebaseManager.shared.firestore.collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener{
                querySnapshot, error in
                if let error = error {
                    self.errorMessage = "failed to listen for recent message: \(error)"
                    return
                }
                
                querySnapshot?.documentChanges.forEach({change in
                    
                    let docId = change.document.documentID
                    if let index = self.recentMessages.firstIndex(where: {rm in
                        return rm.documentId == docId
                    }){
                        self.recentMessages.remove(at: index)
                    }
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                    
                    
                })
            }
    }
    
    func fetchCurrentUser(){
        
        guard let uid =  FirebaseManager.shared.auth.currentUser?.uid else {
            
            self.errorMessage = "could not find firebase uid"
            return}
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument {
            snapshot, error in
            if let error = error {
                self.errorMessage = "failed to fetch current user: \(error)"
                print("failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "no data found"
                return}
            
            self.chatUser = .init(data: data)
           
        }
        
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}


struct MainMessageView: View {
    
    @State var shouldShowLogoutOptions = false
    
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView{
           
            VStack{
                
                
                customNavBar
                messageView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView){
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay( newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            
            
        }
    }
    
    
    private var customNavBar: some View{
        HStack(spacing: 16){
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? "")).resizable().scaledToFill().frame(width: 50, height: 50).clipped().cornerRadius(50) .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1)
            ).shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4){
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                   
                HStack{
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
           
            Spacer()
            Button{
                shouldShowLogoutOptions.toggle()
            }label:{
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
            
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogoutOptions){
            .init(title: Text("settings"), message: Text("what do you want to do ? "), buttons: [
                .destructive(Text("sign out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil){
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
   
    private var messageView: some View{
        ScrollView{
            ForEach(vm.recentMessages){ recentMessages in
                VStack{
                    NavigationLink{
                        Text("destination")
                    }label:{
                        HStack(spacing: 16){
                            WebImage(url: URL(string: recentMessages.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 1))
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading, spacing: 8){
                                Text(recentMessages.email)
                                    .font(.system(size: 16, weight:.bold))
                                    .foregroundColor(Color(.label))
                                Text(recentMessages.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text("123")
                                .font(.system(size: 14, weight:.semibold))
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
           
            
           
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View{
        Button{
            shouldShowNewMessageScreen.toggle()
        }label:{
            HStack{
                Spacer()
                Text("+ new message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .shadow(radius: 15)
                .padding(.horizontal)
        }
        
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen){
            CreateNewMessageView(didSelectNewUser: {
                user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
    
    @State var chatUser: ChatUser?
    
}



struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
            .preferredColorScheme(.dark)
        
        MainMessageView()
    }
}
