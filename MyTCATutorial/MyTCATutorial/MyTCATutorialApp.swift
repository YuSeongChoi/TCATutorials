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
    static let counterStore = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }
    
    static let appStore = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            // MARK: - Case Study 뷰로 실행
//            RootView()
            // MARK: - Tutorial 뷰로 실행
//            CounterTutoView(store: MyTCATutorialApp.counterStore)
            // MARK: - APPState 뷰로 실행
            AppView(store: MyTCATutorialApp.appStore)
        }
    }
}
