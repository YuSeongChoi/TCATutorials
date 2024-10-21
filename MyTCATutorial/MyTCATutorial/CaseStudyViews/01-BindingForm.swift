//
//  01-BindingForm.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/21/24.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
  This file demonstrates how to handle two-way bindings in the Composable Architecture using \
  bindable actions and binding reducers.

  Bindable actions allow you to safely eliminate the boilerplate caused by needing to have a \
  unique action for every UI control. Instead, all UI bindings can be consolidated into a single \
  `binding` action, which the `BindingReducer` can automatically apply to state.

  It is instructive to compare this case study to the "Binding Basics" case study.
  
  이 파일은 사용하여 합성 가능한 아키텍처에서 양방향 바인딩을 처리하는 방법을 보여줍니다
  결합 가능한 작업 및 결합 감소제.

  바인딩 가능한 작업을 통해 발생하는 보일러 플레이트를 안전하게 제거할 수 있습니다
  모든 UI 컨트롤에 대한 고유한 작업입니다. 대신 모든 UI 바인딩을 하나로 통합할 수 있습니다
  '결합 감소제'가 자동으로 상태에 적용할 수 있는 '결합' 작용.

  이 사례 연구를 "구속력 있는 기본" 사례 연구와 비교하는 것이 유익합니다.
  """

@Reducer
struct BindingForm {
    @ObservableState
    struct State: Equatable {
        var sliderValue = 5.0
        var stepCount = 10
        var text = ""
        var toggleIsOn = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case resetButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.stepCount):
                state.sliderValue = .minimum(state.sliderValue, Double(state.stepCount))
                return .none
                
            case .binding:
                return .none
                
            case .resetButtonTapped:
                state = State()
                return .none
            }
        }
    }
}

struct BindingFormView: View {
    @Bindable var store: StoreOf<BindingForm>
    
    var body: some View {
        Form {
            Section {
                AboutView(readMe: readMe)
            }
            
            HStack {
                TextField("Type here", text: $store.text)
                    .disableAutocorrection(true)
                    .foregroundStyle(store.toggleIsOn ? Color.secondary : .primary)
                Text(alternate(store.text))
            }
            .disabled(store.toggleIsOn)
            
            
        }
    }
}

private func alternate(_ string: String) -> String {
    string
        .enumerated()
        .map { idx, char in
            idx.isMultiple(of: 2)
            ? char.uppercased()
            : char.lowercased()
        }
        .joined()
}

#Preview {
    NavigationStack {
        BindingFormView(store: .init(initialState: BindingForm.State(), reducer: {
            BindingForm()
        }))
    }
}
