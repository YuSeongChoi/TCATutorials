//
//  SyncUpFormTests.swift
//  MyTCATutorialTests
//
//  Created by YuSeongChoi on 1/6/25.
//

import XCTest
import ComposableArchitecture

@testable import MyTCATutorial

final class SyncUpFormTests: XCTestCase {
    func addSyncUpNonExhaustive() async {
        let store = TestStore(initialState: SyncUpsList.State()) {
            SyncUpsList()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off(showSkippedAssertions: true)
        
        await store.send(.addSyncUpButtonTapped)
        
        let editedSyncUp = SyncUp(
            id: SyncUp.ID(0),
            attendees: [
                Attendee(id: Attendee.ID(0), name: "Chodan"),
                Attendee(id: Attendee.ID(0), name: "Magenta")
            ],
            title: "QWER"
        )
        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp)
        
        await store.send(.confirmAddButtonTapped) {
          $0.syncUps = [editedSyncUp]
        }
    }
    
    func testAddAttendee() async {
        let store = TestStore(initialState: SyncUpsList.State()) {
          SyncUpsList()
        } withDependencies: {
          $0.uuid = .incrementing
        }


        await store.send(.addSyncUpButtonTapped) {
          $0.addSyncUp = SyncUpForm.State(
            syncUp: SyncUp(id: SyncUp.ID(0))
          )
        }
        
        let editedSyncUp = SyncUp(
            id: SyncUp.ID(0),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Chodan"),
                Attendee(id: Attendee.ID(), name: "Magenta")
            ],
            title: "QWER"
        )
        await store.send(\.addSyncUp.binding.syncUp, editedSyncUp) {
          $0.addSyncUp?.syncUp = editedSyncUp
        }

        await store.send(.confirmAddButtonTapped) {
          $0.addSyncUp = nil
          $0.syncUps = [editedSyncUp]
        }
    }
    
    func testRemoveFocusedAttendee() async {
        let attendee1 = Attendee(id: Attendee.ID())
        let attendee2 = Attendee(id: Attendee.ID())
        let store = TestStore(
            initialState: SyncUpForm.State(
                focus: .attendee(attendee1.id),
                syncUp: SyncUp(
                    id: SyncUp.ID(),
                    attendees: [attendee1, attendee2]
                )
            )
        ) {
            SyncUpForm()
        }
        
        await store.send(.onDeleteAttendees([0])) {
            $0.focus = .attendee(attendee2.id)
            $0.syncUp.attendees = [attendee2]
        }
    }
    
    func testRemoveAttendee() async {
        let store = TestStore(
            initialState: SyncUpForm.State(
                syncUp: SyncUp(
                    id: SyncUp.ID(),
                    attendees: [
                        Attendee(id: Attendee.ID()),
                        Attendee(id: Attendee.ID())
                    ]
                )
            )
        ) {
            SyncUpForm()
        }
        
        await store.send(.onDeleteAttendees([0])) {
            $0.syncUp.attendees.removeFirst()
        }
    }
}
