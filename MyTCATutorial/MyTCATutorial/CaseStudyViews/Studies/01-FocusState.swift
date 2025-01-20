//
//  01-FocusState.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/22/24.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
  This demonstrates how to make use of SwiftUI's `@FocusState` in the Composable Architecture with \
  the library's `bind` view modifier. If you tap the "Sign in" button while a field is empty, the \
  focus will be changed to the first empty field.
  
  이는 구성 가능한 아키텍처에서 SwiftUI의 '@FocusState'를 활용하는 방법을 보여줍니다
  라이브러리의 '바인딩' 보기 수정자입니다. 필드가 비어 있는 동안 "사인인" 버튼을 탭하면
  포커스가 첫 번째 빈 필드로 변경됩니다.
  """

@Reducer
struct FocusDemo {
    @ObservableState
    struct State: Equatable {
        var focusedField: Field?
        var password: String = ""
        var username: String = ""
        
        enum Field: String, Hashable {
            case username, password
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signInButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .signInButtonTapped:
                if state.username.isEmpty {
                    state.focusedField = .username
                } else if state.password.isEmpty {
                    state.focusedField = .password
                }
                return .none
            }
        }
    }
}

struct FocusDemoView: View {
    @Bindable var store: StoreOf<FocusDemo>
    @FocusState var focusedField: FocusDemo.State.Field?
    
    var body: some View {
        Form {
            AboutView(readMe: readMe)
            
            VStack {
                TextField("Username", text: $store.username)
                    .focused($focusedField, equals: .username)
                SecureField("Password", text: $store.password)
                    .focused($focusedField, equals: .password)
                Button("Sign In") {
                    store.send(.signInButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            }
            .textFieldStyle(.roundedBorder)
        }
        // Synchronize store focus state and local focus state.
        .bind($store.focusedField, to: $focusedField)
        .navigationTitle("Focus demo")
    }
}

#Preview {
    NavigationStack {
        FocusDemoView(
            store: Store(initialState: FocusDemo.State()) {
                FocusDemo()
            }
        )
    }
}
