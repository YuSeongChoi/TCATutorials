//
//  ContactsFeature.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 12/5/24.
//

import SwiftUI
import ComposableArchitecture

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

@Reducer
struct ContactsFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var addContact: AddContactFeature.State?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactFeature.State(
                    contact: .init(id: .init(), name: "")
                )
                return .none
                
            case let .addContact(.presented(.delegate(.saveContact(contact)))):
                state.contacts.append(contact)
                return .none
                
            case .addContact:
                return .none
            }
        }
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactFeature()
        }
    }
}

struct ContactsView: View {
    @Bindable var store: StoreOf<ContactsFeature>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    Text(contact.name)
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $store.scope(state: \.addContact, action: \.addContact)) { addContactStore in
                NavigationStack {
                    AddContactView(store: addContactStore)
                }
            }
        }
    }
}

#Preview {
    ContactsView(store: Store(
        initialState: ContactsFeature.State(contacts: [
            Contact(id: UUID(), name: "Chodan"),
            Contact(id: .init(), name: "Magenta"),
            .init(id: .init(), name: "Hina"),
            .init(id: UUID(), name: "Siyeon")
        ]),
        reducer: {
            ContactsFeature()
        })
    )
}
