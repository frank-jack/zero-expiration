//
//  SessionManager.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/23/22.
//

import Foundation
import Amplify

enum AuthState {
    case signUp
    case logIn
    case confirmCode(username: String)
    case session(user: AuthUser)
    case reset
}

final class SessionManager: ObservableObject {
    @Published var authState: AuthState = .logIn
    var email = ""
    
    func getCurrentAuthUser() {
        if let user = Amplify.Auth.getCurrentUser() {
            authState = .session(user: user)
        } else {
            authState = .logIn
        }
    }
    
    func showSignUp() {
        authState = .signUp
    }
    
    func showLogIn() {
        authState = .logIn
    }
    
    func showReset() {
        authState = .reset
    }
    
    func signUp(username: String, email: String, password: String) {
        let attributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        
        _ = Amplify.Auth.signUp(
            username: username,
            password: password,
            options: options
        ) { [weak self] result in
            
            switch result {
            
            case .success(let signUpResult):
                print("Sign up result:", signUpResult)
                
                switch signUpResult.nextStep {
                case .done:
                    print("Finished sign up")
                    
                case .confirmUser(let details, _):
                    print(details ?? "no details")
                    
                    DispatchQueue.main.async {
                        self?.authState = .confirmCode(username: username)
                    }
                }
                
            case .failure(let error):
                print("Sign up error", error)
            }
            
        }
    }
    
    
    func confirm(username: String, code: String) {
        _ = Amplify.Auth.confirmSignUp(
            for: username,
            confirmationCode: code
        ) { [weak self] result in
            
            switch result {
            case .success(let confirmResult):
                print(confirmResult)
                if confirmResult.isSignupComplete {
                    DispatchQueue.main.async {
                        self?.showLogIn()
                    }
                }
                
            case .failure(let error):
                print("failed to confirm code:", error)
            }
        }
    }
    
    func logIn(username: String, password: String) {
        _ = Amplify.Auth.signIn(
            username: username,
            password: password
        ) { [weak self] result in
            
            switch result {
            case .success(let signInResult):
                self!.email = username
                print(signInResult)
                if signInResult.isSignedIn {
                    DispatchQueue.main.async {
                        self?.getCurrentAuthUser()
                    }
                }
                
            case .failure(let error):
                print("Log In error:", error)
            }
        }
    }
    
    func signOut() {
        _ = Amplify.Auth.signOut { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.getCurrentAuthUser()
                }
                
            case .failure(let error):
                print("Sign out error:", error)
            }
        }
    }
    
    func resetPassword(username: String) {
        Amplify.Auth.resetPassword(for: username) { result in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info))")
                case .done:
                    print("Reset completed")
                }
            } catch {
                print("Reset password failed with error \(error)")
            }
        }
    }
    
    func confirmResetPassword(username: String, newPassword: String, confirmationCode: String) {
        Amplify.Auth.confirmResetPassword(
            for: username,
            with: newPassword,
            confirmationCode: confirmationCode
        ) { result in
            switch result {
            case .success:
                print("Password reset confirmed")
            case .failure(let error):
                print("Reset password failed with error \(error)")
            }
        }
    }
}
