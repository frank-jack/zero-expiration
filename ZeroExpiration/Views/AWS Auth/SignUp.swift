//
//  SignUp.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/23/22.
//

import SwiftUI

struct SignUp: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State var password = ""
    @State var email = ""
    @State private var tempText = ""
    var body: some View {
        VStack {
            Spacer()
            TextField("Email", text: $email)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
            Text(tempText)
            Button("Sign Up") {
                if password.count < 8 {
                    tempText = "Password must be at least 8 characters"
                } else {
                    sessionManager.signUp(username: email, email: email, password: password)
                }
            }
            Spacer()
            Button("Already have an account? Log in.", action: sessionManager.showLogIn)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
