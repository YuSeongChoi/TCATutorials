//
//  02-SharedStateUserDefaults.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 1/17/25.
//
//
import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates how multiple independent screens can share state in the Composable \
  Architecture through user defaults (i.e. "app storage"). Each tab manages its own state, and \
  could be in separate modules, but changes in one tab are immediately reflected in the other, and \
  all changes are persisted to use defaults.

  This tab has its own state, consisting of a count value that can be incremented and decremented, \
  as well as an alert value that is set when asking if the current count is prime.
  
  이 화면은 여러 독립 화면이 Composable에서 상태를 공유할 수 있는 방법을 보여줍니다
  사용자 기본 설정(즉, "앱 스토리지")을 통한 아키텍처. 각 탭은 자체 상태를 관리합니다
  별도의 모듈에 포함될 수 있지만, 한 탭의 변경 사항은 즉시 다른 탭에 반영됩니다
  모든 변경 사항은 기본값을 사용하도록 지속됩니다.

  이 탭에는 증가 및 감소할 수 있는 카운트 값으로 구성된 자체 상태가 있습니다
  현재 카운트가 소수인지 물어볼 때 설정되는 경고 값도 포함됩니다.
  """

@Reducer
struct SharedStateUserDefaults {
    enum Tab { case counter, profile }
    
    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.counter
        var counter = CounterTab.State()
        var profile = ProfileTab.State()
    }
    
    enum Action {
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

extension SharedStateUserDefaults {
    @Reducer
    struct CounterTab {
        @ObservableState
        struct State: Equatable {
            @Presents var alert: AlertState<Action.Alert>?
            @Shared(.count) var count = 0
        }
        
        enum Action {
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
                    state.$count.withLock { $0 -= 1 }
                    return .none
                    
                case .incrementButtonTapped:
                    state.$count.withLock { $0 += 1 }
                    return .none
                    
                case .isPrimeButtonTapped:
                    state.alert = AlertState {
                        TextState(
                            isPrime(state.count)
                              ? "👍 The number \(state.count) is prime!"
                              : "👎 The number \(state.count) is not prime :("
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
            @Shared(.count) var count = 0
        }
        
        enum Action {
            case resetStateButtonTapped
        }
        
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .resetStateButtonTapped:
                    state.$count.withLock { $0 = 0 }
                    return .none
                }
            }
        }
    }
}

struct SharedStateUserDefaultsView: View {
    @Bindable var store: StoreOf<SharedStateUserDefaults>
    
    var body: some View {
        TabView(selection: $store.currentTab.sending(\.selectTab)) {
            CounterTabView(store: store.scope(state: \.counter, action: \.counter))
                .tag(SharedStateUserDefaults.Tab.counter)
                .tabItem { Text("Counter") }
            
            ProfileTabView(store: store.scope(state: \.profile, action: \.profile))
                .tag(SharedStateUserDefaults.Tab.profile)
                .tabItem { Text("Profile") }
        }
        .navigationTitle("Shared State Demo")
    }
}

private struct CounterTabView: View {
    @Bindable var store: StoreOf<SharedStateUserDefaults.CounterTab>
    
    var body: some View {
        Form {
            AboutView(readMe: readMe)
            
            VStack(spacing: 16) {
                HStack {
                    Button {
                        store.send(.decrementButtonTapped)
                    } label: {
                        Image(systemName: "minus")
                    }
                    
                    Text("\(store.count)")
                        .monospacedDigit()
                    
                    Button {
                        store.send(.incrementButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                Button("Is this prime?"){ store.send(.isPrimeButtonTapped) }
            }
        }
        .buttonStyle(.borderless)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

private struct ProfileTabView: View {
    let store: StoreOf<SharedStateUserDefaults.ProfileTab>
    
    var body: some View {
        Form {
            Section {
                AboutView(
                    readMe: """
          This tab shows the count from the previous tab, and it is capable of resetting the count \
          back to 0.

          This shows that it is possible for each screen to model its state in the way that makes \
          the most sense for it, while still allowing the state and mutations to be shared \
          across independent screens.
          """
                )
                
                VStack(spacing: 16) {
                    Text("Current count : \(store.count)")
                    Button("Reset") { store.send(.resetStateButtonTapped) }
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

extension SharedKey where Self == AppStorageKey<Int> {
    fileprivate static var count: Self {
        appStorage("sharedStateDemoCount")
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
    SharedStateUserDefaultsView(store: Store(initialState: SharedStateUserDefaults.State()) { SharedStateUserDefaults() })
}
