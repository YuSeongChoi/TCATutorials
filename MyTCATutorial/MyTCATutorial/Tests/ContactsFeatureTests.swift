//
//  ContactsFeatureTests.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 12/11/24.
//

import ComposableArchitecture
import XCTest

@testable import MyTCATutorial

@MainActor
final class ContactsFeatureTests: XCTestCase {
    
    func testAddFlow() async {
        let store = TestStore(initialState: ContactsFeature.State()) {
          ContactsFeature()
        } withDependencies: {
          $0.uuid = .incrementing
        }
        
        await store.send(.addButtonTapped) {
          $0.destination = .addContact(
            AddContactFeature.State(
              contact: Contact(id: UUID(0), name: "")
            )
          )
        }
        await store.send(\.destination.addContact.setName, "Siyoming") {
            $0.destination = .addContact(.init(contact: .init(id: UUID(0), name: "Siyoming")))
        }
        await store.send(\.destination.addContact.saveButtonTapped)
        await store.receive(
          \.destination.addContact.delegate.saveContact,
          Contact(id: UUID(0), name: "Siyoming")
        ) {
          $0.contacts = [
            Contact(id: UUID(0), name: "Siyoming")
          ]
        }
        await store.receive(\.destination.dismiss) {
          $0.destination = nil
        }
    }
    
    func testAddFlowNonExhaustive() async {
        let store = TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off
        
        await store.send(.addButtonTapped)
        await store.send(\.destination.addContact.setName, "Siyoming")
        await store.send(\.destination.addContact.saveButtonTapped)
        await store.skipReceivedActions()
        store.assert {
            $0.contacts = [
                Contact(id: UUID(0), name: "Siyoming")
            ]
            $0.destination = nil
        }
    }
    
    func testDeleteContact() async {
        let store = TestStore(initialState: ContactsFeature.State(
            contacts: [
                Contact(id: UUID(0), name: "Chodan"),
                Contact(id: UUID(1), name: "Magenta")
            ]
        )) {
            ContactsFeature()
        }
        
        await store.send(.deleteButtonTapped(id: UUID(1))) {
            $0.destination = .alert(.deleteConfirmation(id: UUID(1)))
        }
        await store.send(.destination(.presented(.alert(.confirmDeletion(id: UUID(1)))))) {
            $0.contacts.remove(id: UUID(1))
            $0.destination = nil
        }
    }
}
