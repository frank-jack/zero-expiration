//
//  Reset.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/23/22.
//

import SwiftUI

struct Reset: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var email = ""
    @State private var code = ""
    @State private var newPassword = ""
    @State private var showConfirm = false
    @State private var text1 = "Cancel"
    @State private var text2 = ""
    var body: some View {
        VStack{
            if !showConfirm {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                Button("Reset Password") {
                    sessionManager.resetPassword(username: email)
                    showConfirm = true
                }
            }
            if showConfirm {
                TextField("Confirmation Code sent to your email", text: $code)
                SecureField("New Password", text: $newPassword)
                Text(text2)
                Button("Confirm New Password") {
                    if newPassword.count < 8 {
                        text2 = "New password must be at least 8 characters"
                    } else {
                        sessionManager.confirmResetPassword(username: email, newPassword: newPassword, confirmationCode: code)
                        text1 = "New Password Confirmed"
                    }
                }
            }
            Button(text1, action: sessionManager.showLogIn)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

struct Reset_Previews: PreviewProvider {
    static var previews: some View {
        Reset()
    }
}
