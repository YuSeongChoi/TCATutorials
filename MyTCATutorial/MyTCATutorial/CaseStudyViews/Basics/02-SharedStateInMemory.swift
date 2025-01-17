//
//  02-SharedStateInMemory.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 1/14/25.
//

import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates how multiple independent screens can share state in the Composable \
  Architecture through an in-memory reference. Each tab manages its own state, and \
  could be in separate modules, but changes in one tab are immediately reflected in the other.

  This tab has its own state, consisting of a count value that can be incremented and decremented, \
  as well as an alert value that is set when asking if the current count is prime.

  Internally, it is also keeping track of various stats, such as min and max counts and total \
  number of count events that occurred. Those states are viewable in the other tab, and the stats \
  can be reset from the other tab.
  
  이 화면은 여러 독립 화면이 Composable에서 상태를 공유할 수 있는 방법을 보여줍니다
  인메모리 참조를 통한 아키텍처. 각 탭은 자체 상태를 관리하며, 별도의 모듈에 포함될 수 있지만, 한 탭의 변경 사항은 즉시 다른 탭에 반영됩니다.\\

  이 탭에는 증가 및 감소할 수 있는 카운트 값으로 구성된 자체 상태가 있습니다
  현재 카운트가 소수인지 물어볼 때 설정되는 경고 값도 포함됩니다. \\

  내부적으로는 최소 및 최대 개수, 총합 등 다양한 통계를 추적하고 있습니다
  발생한 카운트 이벤트의 수. 해당 상태는 다른 탭에서 볼 수 있으며, 통계는  다른 탭에서 재설정할 수 있습니다.
  """

@Reducer
struct SharedStateInMemory {
    enum Tab { case counter, profile }
    
    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.counter
        var counter = CounterTab.State()
        var profile = ProfileTab.State()
    }
    
    enum Action: Sendable {
        case counter(CounterTab.Action)
        case profile(ProfileTab.Action)
        case selectTab(Tab)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.counter, action: \.counter) {
            CounterTab()
        }
        Scope(state: \.profile, action: \.profile) {
            ProfileTab()
        }
        
        Reduce { state, action in
            switch action {
            case .counter, .profile:
                return .none
            case let .selectTab(tab):
                state.currentTab = tab
                return .none
            }
        }
    }
}

extension SharedStateInMemory {
    @Reducer
    struct CounterTab {
        @ObservableState
        struct State: Equatable {
            @Presents var alert: AlertState<Action.Alert>?
            @Shared(.stats) var stats = Stats()
        }
        
        enum Action: Sendable {
            case alert(PresentationAction<Alert>)
            case decrementButtonTapped
            case incrementButtonTapped
            case isPrimeButtonTapped
            
            enum Alert: Equatable {}
        }
        
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .alert:
                    return .none
                    
                case .decrementButtonTapped:
                    state.$stats.withLock { $0.decrement() }
                    return .none
                    
                case .incrementButtonTapped:
                    state.$stats.withLock { $0.increment() }
                    return .none
                    
                case .isPrimeButtonTapped:
                    state.alert = AlertState {
                        TextState(
                            isPrime(state.stats.count)
                              ? "👍 The number \(state.stats.count) is prime!"
                              : "👎 The number \(state.stats.count) is not prime :("
                        )
                    }
                    return .none
                }
            }
            .ifLet(\.$alert, action: \.alert)
        }
    }
    
    @Reducer
    struct ProfileTab {
        @ObservableState
        struct State: Equatable {
            @Shared(.stats) var stats = Stats()
        }
        
        enum Action: Sendable {
            case resetStatsButtonTapped
        }
        
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .resetStatsButtonTapped:
                    state.$stats.withLock { $0 = Stats() }
                    return .none
                }
            }
        }
    }
}

struct SharedStateInMemoryView: View {
    @Bindable var store: StoreOf<SharedStateInMemory>
    
    var body: some View {
        TabView(selection: $store.currentTab.sending(\.selectTab)) {
            CounterTabView(store: store.scope(state: \.counter, action: \.counter))
                .tag(SharedStateInMemory.Tab.counter)
                .tabItem {
                    Text("Counter")
                }
            
            ProfileTabView(store: store.scope(state: \.profile, action: \.profile))
                .tag(SharedStateInMemory.Tab.profile)
                .tabItem {
                    Text("Profile")
                }
        }
        .navigationTitle("Shared State Demo")
    }
}

private struct CounterTabView: View {
    @Bindable var store: StoreOf<SharedStateInMemory.CounterTab>
    
    var body: some View {
        Form {
            Section {
                AboutView(readMe: readMe)
            }
            
            VStack(spacing: 16) {
                HStack {
                    Button {
                        store.send(.decrementButtonTapped)
                    } label: {
                        Image(systemName: "minus")
                    }
                    
                    Text("\(store.stats.count)")
                        .monospacedDigit()
                    
                    Button {
                        store.send(.incrementButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                Button("Is this prime?") { store.send(.isPrimeButtonTapped) }
            }
        }
        .buttonStyle(.borderless)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

private struct ProfileTabView: View {
    let store: StoreOf<SharedStateInMemory.ProfileTab>
    
    var body: some View {
        Form {
            Section {
                AboutView(readMe: """
          This tab shows state from the previous tab, and it is capable of resetting all of the \
          state back to 0.

          This shows that it is possible for each screen to model its state in the way that makes \
          the most sense for it, while still allowing the state and mutations to be shared \
          across independent screens.
          """
                )
            }
            
            VStack(spacing: 16) {
                Text("Current count : \(store.stats.count)")
                Text("Max count : \(store.stats.maxCount)")
                Text("Min count : \(store.stats.minCount)")
                Text("Total number of count events: \(store.stats.numberOfCounts)")
                Button("Reset") { store.send(.resetStatsButtonTapped) }
            }
        }
        .buttonStyle(.borderless)
    }
}

extension SharedKey where Self == InMemoryKey<Stats> {
    fileprivate static var stats: Self {
        inMemory("stats")
    }
}

/// Checks if a number is prime or not.
private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

#Preview {
    SharedStateInMemoryView(store: Store(initialState: SharedStateInMemory.State()) {
        SharedStateInMemory()
    })
}
