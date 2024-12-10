//
//  AppFeatureTests.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 11/22/24.
//

import ComposableArchitecture
import XCTest

@testable import MyTCATutorial

@MainActor
final class AppFeatureTests: XCTestCase {
    func incrementInFirstTab() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
        
    }
}

