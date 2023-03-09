//
//  ExpirableLabel.swift
//  ZeroExpiration
//
//  Created by Jack Frank on 7/22/22.
//

import SwiftUI

struct ExpirableLabel: View {
    var expirable: Expirable
    var body: some View {
        Text(expirable.name)
    }
}

/*struct ExpirableLabel_Previews: PreviewProvider {
    static var previews: some View {
        ExpirableLabel(expirable: <#Expirable#>)
    }
}*/
