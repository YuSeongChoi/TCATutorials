//
//  CounterFeature.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 11/18/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CounterFeature {
    @ObservableState
    struct State {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case timerTick
        case toggleTimerButtonTapped
    }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                return .run { [count = state.count] send in
                    // ✅ Do async work in here, and send actions back into the system.
                    let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(count)")!)
                    let fact = String(decoding: data, as: UTF8.self)
                    /*
                     Q. state.fact = fact <-- 가 안되는 이유
                     네트워크에서 데이터를 가져온 후 이펙트에서 뮤테이션을 하는건 불가능하다.
                     이는 Sendable 클로저가 상태를 캡처할 수 없기 때문에 컴파일러에서 엄격하게 적용한다.
                     이는 라이브러리가 리듀서가 수행하는 상태 뮤테이션과 이펙트를 분리하는 방법을 보여준다.
                     
                     However, it is not possible to then mutate the state.fact in the effect after fetching the data from the network. This is strictly enforced by the compiler since sendable closures cannot capture inout state. This is showing how the library chooses to separate the nice, simple and pure state mutations that reducers perform from the messy, complex effects.
                  */
                    await send(.factResponse(fact))
                }
                
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
                
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        while true {
                            try await Task.sleep(for: .seconds(1))
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
}

struct CounterTutoView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        VStack {
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(1)
            
            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
                Button(store.isTimerRunning ? "Stop timer" : "Start Timer") {
                    store.send(.toggleTimerButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button("Fact") {
                store.send(.factButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)
            
            if store.isLoading {
                ProgressView()
            } else if let fact = store.fact {
                Text(fact)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

#Preview {
    CounterTutoView(
        store: Store(initialState: CounterFeature.State()) {
            CounterFeature()
        }
    )
}
