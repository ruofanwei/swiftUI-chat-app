//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/1.
//

import SwiftUI

struct MainMessageView: View {
    
    @State var shouldShowLogoutOptions = false
    
    private var customNavBar: some View{
        HStack(spacing: 16){
            
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4){
                Text("USEERNAME")
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
                }),
                .cancel()
            ])
        }
    }
    
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
