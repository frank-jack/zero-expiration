//
//  LogIn.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/23/22.
//

import SwiftUI

struct LogIn: View {
    @EnvironmentObject var modelData: ModelData
    @EnvironmentObject var sessionManager: SessionManager
    @State var email = ""
    @State var password = ""
    var body: some View {
        VStack {
            Spacer()
            TextField("Email", text: $email)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
            Button("Forgot your password?", action: sessionManager.showReset)
            Spacer()
            Button("Log In", action: {sessionManager.logIn(username: email, password: password)})
            Spacer()
            Button("Log In as Guest") {
                sessionManager.logIn(username: "support@zeroexpiration.com" , password: "abcdefghijklmnopqrstuvwxyz")
                print("Logged In")
            }
            Button("Don't have an account? Sign up.", action: sessionManager.showSignUp)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct LogIn_Previews: PreviewProvider {
    static var previews: some View {
        LogIn()
            .environmentObject(ModelData())
    }
}
