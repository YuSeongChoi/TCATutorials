//
//  AboutView.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/17/24.
//

import SwiftUI

struct AboutView: View {
    let readMe: String
    
    var body: some View {
        DisclosureGroup("case study 설명") {
            Text(template: self.readMe)
        }
    }
}
