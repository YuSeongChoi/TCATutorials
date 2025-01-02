//
//  SyncUpsListTests.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 12/27/24.
//

import ComposableArchitecture
import Testing
import XCTest

@testable import MyTCATutorial

@MainActor
struct SyncUpsListTests {
    @Test("삭제 테스트")
    func deletion() async throws {
        let store = TestStore(
            initialState: SyncUpsList.State(
                syncUps: [
                    SyncUp(
                        id: SyncUp.ID(),
                        title: "Point-Free Morning Sync"
                    )
                ]
            )
        ) {
            SyncUpsList()
        }
        
        await store.send(.onDelete([0])) {
            $0.syncUps = []
        }
    }
}
