//
//  LoginView.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/1.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage



struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    
    @State private var shouldShowImagePicker = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack(spacing: 16){
                    Picker(selection: $isLoginMode, label: Text("picker here")) {
                    Text("Login")
                            .tag(true)
                    Text("Create Account")
                            .tag(false)
                }.pickerStyle(SegmentedPickerStyle())
                        
                    if !isLoginMode{
                        Button{
                            shouldShowImagePicker
                                .toggle()
                        }label: {
                            
                            VStack{
                                
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                        
                                }else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
                                
                            
                        }
                    }
                    
                    Group{
                        TextField("Email", text: $email )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password )
                    }
                    .padding(12)
                    .background(Color.white)
                                        
                    Button{
                        handleAction()
                    }label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Login" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                    Text(self.loginStatusMessage).foregroundColor(.red)
                    
                }
                .padding()
                }
               
                .navigationTitle(isLoginMode ? "Login" : "Create Account")
                .background(Color(.init(white: 0,  alpha: 0.05))
                                .ignoresSafeArea())
        }
        
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
    
    }
    
    
    
    private func handleAction(){
        if isLoginMode {
            loginUser()
        }else{
            createNewAccount()
        }
    }
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){
            result, err in
            if let err = err {
                print("Failed to logi user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            
            
            
            self.didCompleteLoginProcess()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        
        if self.image == nil {
            self.loginStatusMessage = "you must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            
            
           
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage(){
       
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)else{return}
        ref.putData(imageData, metadata: nil){
            metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to storage: \(err)"
                return
            }
            
            ref.downloadURL{url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrive downloadURL: \(err)"
                    return
                }
               
                
                
                guard let url = url else {return}
                self.storeUserInfomation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInfomation(imageProfileUrl: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData){
                err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                
                self.didCompleteLoginProcess()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {
            
        })
    }
}
