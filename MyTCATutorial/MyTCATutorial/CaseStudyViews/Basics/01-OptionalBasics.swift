//
//  01-OptionalBasics.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/23/24.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
  This screen demonstrates how to show and hide views based on the presence of some optional child \
  state.

  The parent state holds a `Counter.State?` value. When it is `nil` we will default to a plain \
  text view. But when it is non-`nil` we will show a view fragment for a counter that operates on \
  the non-optional counter state.

  Tapping "Toggle counter state" will flip between the `nil` and non-`nil` counter states.
  
  이 화면은 일부 선택적 자녀의 존재를 기준으로 보기를 표시하고 숨기는 방법을 보여줍니다

  상위 상태는 'Counter.State?' 값을 보유합니다. 'nil'이면 일반으로 기본 설정됩니다
  텍스트 보기. 하지만 non'non'non'il'일 때는 작동하는 카운터에 대한 보기 조각을 표시합니다
  비선택 사항 카운터 상태

  "토글 카운터 상태"를 탭하면 '닐' 카운터 상태와 '닐' 카운터가 아닌 카운터 상태가 바뀝니다.
  """

@Reducer
struct OptionalBasics {
    @ObservableState
    struct State: Equatable {
        var optionalCounter: Counter.State?
    }
    
    enum Action {
        case optionalCounter(Counter.Action)
        case toggleCounterButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleCounterButtonTapped:
                state.optionalCounter = state.optionalCounter == nil ? Counter.State() : nil
                return .none
                
            case .optionalCounter:
                return .none
            }
        }
        .ifLet(\.optionalCounter, action: \.optionalCounter) {
            Counter()
        }
    }
}

struct OptionalBasicsView: View {
    let store: StoreOf<OptionalBasics>
    
    var body: some View {
        Form {
            Section {
                AboutView(readMe: readMe)
            }
            
            Button("Toggle counter state") {
                store.send(.toggleCounterButtonTapped)
            }
            
            if let store = store.scope(state: \.optionalCounter, action: \.optionalCounter) {
                Text(template: "`Counter.State` is non-`nil`")
                CounterView(store: store)
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity)
            } else {
                Text(template: "`Counter.State` is `nil`")
            }
        }
        .navigationTitle("Optional State")
    }
}

#Preview {
    NavigationStack {
        OptionalBasicsView(store: Store(initialState: OptionalBasics.State(), reducer: {
            OptionalBasics()
        }))
    }
}
