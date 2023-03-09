//
//  Session.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/23/22.
//

import SwiftUI
import Amplify

struct Session: View {
    @EnvironmentObject var sessionManager: SessionManager
    //let user: AuthUser
    @State var user: AuthUser
    var body: some View {
        Text("")
    }
}

struct Session_Previews: PreviewProvider {
    private struct DummyUser: AuthUser {
        let userId: String = "1"
        let username: String = "dummy"
    }
    
    static var previews: some View {
        Session(user: DummyUser())
    }
}
