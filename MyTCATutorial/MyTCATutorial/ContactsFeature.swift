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
        @Presents var destination: Destination.State?
//        @Presents var addContact: AddContactFeature.State?
//        @Presents var alert: AlertState<Action.Alert>?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    
    enum Action {
        case addButtonTapped
        case deleteButtonTapped(id: Contact.ID)
        case destination(PresentationAction<Destination.Action>)
//        case addContact(PresentationAction<AddContactFeature.Action>)
//        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
//                state.addContact = AddContactFeature.State(contact: Contact(id: .init(), name: ""))
                state.destination = .addContact(
                  AddContactFeature.State(
                    contact: Contact(id: UUID(), name: "")
                  )
                )
                return .none
                
//            case let .addContact(.presented(.delegate(.saveContact(contact)))):
            case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
                state.contacts.append(contact)
                return .none
                                                
            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                state.contacts.remove(id: id)
                return .none
                
            case .destination:
                return .none
                
            case let .deleteButtonTapped(id: id):
                state.destination = .alert(
                    AlertState {
                        TextState("삭제하시겠습니까?")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                            TextState("삭제")
                        }
                    }
                )
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ContactsFeature {
    @Reducer
    enum Destination {
        case addContact(AddContactFeature)
        case alert(AlertState<ContactsFeature.Action.Alert>)
    }
}

extension ContactsFeature.Destination.State: Equatable {}

struct ContactsView: View {
    @Bindable var store: StoreOf<ContactsFeature>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    HStack {
                        Text(contact.name)
                        Spacer()
                        Button {
                            store.send(.deleteButtonTapped(id: contact.id))
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
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
        }
//        .sheet(
//            item: $store.scope(state: \.destination?.addContact, action: \.destination?.addContact)
//        ) { addContactStore in
//            NavigationStack {
//                AddContactView(store: addContactStore)
//            }
//        }
//        .alert($store.scope(state: \.destination?.alert, action: \.destination?.alert))
        .sheet(item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact)) { addContactStore in
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
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
