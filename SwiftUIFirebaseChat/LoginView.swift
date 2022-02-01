//
//  LoginView.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/1.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
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
                            
                        }label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
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
                    
                }
                .padding()
                }
               
                .navigationTitle(isLoginMode ? "Login" : "Create Account")
                .background(Color(.init(white: 0,  alpha: 0.05))
                                .ignoresSafeArea())
        }
        
    }
    
    private func handleAction(){
        if isLoginMode {
            print("log in to firebase")
        }else{
            print("create a new account")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
