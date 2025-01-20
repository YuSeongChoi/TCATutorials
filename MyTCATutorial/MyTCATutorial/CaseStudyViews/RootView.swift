//
//  ContentView.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/16/24.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @State var isNavigationStackCaseStudyPresented = false
    @State var isSignUpCaseStudyPresented = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("Basics") {
                        Demo(store: Store(initialState: Counter.State()) { Counter() }) { store in
                            CounterDemoView(store: store)
                        }
                    }
                    NavigationLink("Combining reducers") {
                        Demo(store: Store(initialState: TwoCounters.State()) { TwoCounters() }) { store in
                            TwoCountersView(store: store)
                        }
                    }
                    NavigationLink("Bindings") {
                        Demo(store: Store(initialState: BindingBasics.State()) { BindingBasics() }) { store in
                            BindingBasicsView(store: store)
                        }
                    }
                    NavigationLink("Form bindings") {
                        Demo(store: Store(initialState: BindingForm.State()) { BindingForm() }) { store in
                            BindingFormView(store: store)
                        }
                    }
                    NavigationLink("Optional state") {
                        Demo(store: Store(initialState: OptionalBasics.State()) { OptionalBasics() }) { store in
                            OptionalBasicsView(store: store)
                        }
                    }
                    NavigationLink("Alerts and Confirmation Dialogs") {
                        Demo(store: Store(initialState: AlertAndConfirmationDialog.State()) { AlertAndConfirmationDialog() }) { store in
                            AlertAndConfirmationDialogView(store: store)
                        }
                    }
                    NavigationLink("Focus State") {
                        Demo(store: Store(initialState: FocusDemo.State()) { FocusDemo() }) { store in
                            FocusDemoView(store: store)
                        }
                    }
                    NavigationLink("Animations") {
                        Demo(store: Store(initialState: Animations.State()) { Animations() }) { store in
                            AnimationsView(store: store)
                        }
                    }
                } header: {
                    Text("Getting started")
                }
                
                Section {
                  NavigationLink("In memory") {
                    Demo(
                      store: Store(initialState: SharedStateInMemory.State()) { SharedStateInMemory() }
                    ) { store in
                      SharedStateInMemoryView(store: store)
                    }
                  }
                  NavigationLink("User defaults") {
                    Demo(
                      store: Store(initialState: SharedStateUserDefaults.State()) {
                          SharedStateUserDefaults()
                      }
                    ) { store in
                      SharedStateUserDefaultsView(store: store)
                    }
                  }
                  NavigationLink("File storage") {
                    Demo(
                      store: Store(initialState: SharedStateFileStorage.State()) {
                        SharedStateFileStorage()
                      }
                    ) { store in
                      SharedStateFileStorageView(store: store)
                    }
                  }
                  Button("Sign up flow") {
                    isSignUpCaseStudyPresented = true
                  }
                  .sheet(isPresented: $isSignUpCaseStudyPresented) {
                    SignUpFlow()
                  }
                } header: {
                  Text("Shared state")
                }
            }
        }
    }
}

/// This wrapper provides an "entry" point into an individual demo that can own a store.
struct Demo<State, Action, Content: View>: View {
    @SwiftUI.State var store: Store<State, Action>
    let content: (Store<State, Action>) -> Content
    
    init(
        store: Store<State, Action>,
        @ViewBuilder content: @escaping (Store<State, Action>) -> Content
    ) {
        self.store = store
        self.content = content
    }
    
    var body: some View {
        content(store)
    }
}

#Preview {
    RootView()
}
