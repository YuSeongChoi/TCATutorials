//
//  MyTCATutorialApp.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/16/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct MyTCATutorialApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            // MARK: - Case Study 뷰로 실행
            RootView()
            // MARK: - Tutorial 뷰로 실행
//            CounterTutoView(store: MyTCATutorialApp.store)
        }
    }
}
