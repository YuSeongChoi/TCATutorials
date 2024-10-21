//
//  01-BindingBasics.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/21/24.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
  This file demonstrates how to handle two-way bindings in the Composable Architecture.

  Two-way bindings in SwiftUI are powerful, but also go against the grain of the "unidirectional \
  data flow" of the Composable Architecture. This is because anything can mutate the value \
  whenever it wants.

  On the other hand, the Composable Architecture demands that mutations can only happen by sending \
  actions to the store, and this means there is only ever one place to see how the state of our \
  feature evolves, which is the reducer.

  Any SwiftUI component that requires a binding to do its job can be used in the Composable \
  Architecture. You can derive a binding from a store by taking a bindable store, chaining into a \
  property of state that renders the component, and calling the `sending` method with a key path \
  to an action to send when the component changes, which means you can keep using a unidirectional \
  style for your feature.
  
  이 파일은 합성 가능한 아키텍처에서 양방향 바인딩을 처리하는 방법을 보여줍니다.

  SwiftUI의 양방향 바인딩은 강력하지만 "단방향"의 곡물에도 위배됩니다
  구성 가능한 아키텍처의 데이터 흐름". 그 이유는 무엇이든 값을 변형시킬 수 있기 때문입니다
  원할 때 언제든지.

  반면에 합성 가능한 아키텍처는 다음을 전송해야만 돌연변이가 발생할 수 있다고 요구합니다
  스토어에 대한 조치, 즉 우리의 상태를 볼 수 있는 곳은 단 한 곳뿐입니다
  기능이 진화합니다.

  작업을 수행하기 위해 바인딩이 필요한 SwiftUI 구성 요소는 Composable에서 사용할 수 있습니다
  아키텍처. 바인딩 가능한 스토어를 가져다가 체인을 연결하여 스토어에서 바인딩을 유도할 수 있습니다
  구성 요소를 렌더링하는 상태의 속성, 키 경로가 있는 'sending' 방법 호출
  구성 요소가 변경될 때 전송할 작업으로, 단방향을 계속 사용할 수 있습니다
  기능에 맞게 스타일을 지정합니다.
  """

@Reducer
struct BindingBasics {
    @ObservableState
    struct State: Equatable {
        var sliderValue = 5.0
        var stepCount = 10
        var text = ""
        var toggleIsOn = false
    }
    
    enum Action {
        case sliderValueChanged(Double)
        case stepCountChanged(Int)
        case textChanged(String)
        case toggleChanged(isOn: Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .sliderValueChanged(value):
                state.sliderValue = value
                return .none
                
            case let .stepCountChanged(count):
                state.sliderValue = .minimum(state.sliderValue, Double(count))
                state.stepCount = count
                return .none
                
            case let .textChanged(text):
                state.text = text
                return .none
                
            case let .toggleChanged(isOn: isOn):
                state.toggleIsOn = isOn
                return .none
            }
        }
    }
}

struct BindingBasicsView: View {
    @Bindable var store: StoreOf<BindingBasics>
    
    var body: some View {
        Form {
            Section {
                AboutView(readMe: readMe)
            }
            
            HStack {
                TextField("Type here", text: $store.text.sending(\.textChanged))
                    .disableAutocorrection(true)
                    .foregroundStyle(store.toggleIsOn ? Color.secondary : .primary)
                Text(alternate(store.text))
            }
            .disabled(store.toggleIsOn)
            
            Toggle("Disable other controls", isOn: $store.toggleIsOn.sending(\.toggleChanged).resignFirstResponder())
            
            Stepper("Max slider value: \(store.stepCount)", value: $store.stepCount.sending(\.stepCountChanged), in: 0...100)
                .disabled(store.toggleIsOn)
            
            HStack {
                Text("Slider value: \(Int(store.sliderValue))")
                Slider(value: $store.sliderValue.sending(\.sliderValueChanged), in: 0...Double(store.stepCount))
                    .tint(.accentColor)
            }
            .disabled(store.toggleIsOn)
        }
        .monospacedDigit()
        .navigationTitle("Bindinggs basics")
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
        BindingBasicsView(store: .init(initialState: BindingBasics.State()) {
            BindingBasics()
        })
    }
}
