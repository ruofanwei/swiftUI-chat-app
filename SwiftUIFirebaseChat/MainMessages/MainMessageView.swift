//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/1.
//

import SwiftUI
import SDWebImageSwiftUI


class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        
        fetchCurrentUser()
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
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView{
           
            VStack{
                
                
                customNavBar
                messageView
            }
            .overlay( newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            
            .navigationTitle("title")
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
            ForEach(0..<10, id: \.self){ num in
                VStack{
                    HStack(spacing: 16){
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                            )
                        
                        
                        
                        VStack(alignment: .leading){
                            Text("User name")
                                .font(.system(size: 16, weight:.bold))
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        Text("123")
                            .font(.system(size: 14, weight:.semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
           
            
           
        }
    }
    
    private var newMessageButton: some View{
        Button{
            
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
    }
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
            .preferredColorScheme(.dark)
    }
}
