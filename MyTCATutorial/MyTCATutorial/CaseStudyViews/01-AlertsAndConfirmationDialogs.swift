//
//  01-AlertsAndConfirmationDialogs.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/17/24.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
이는 TCA에서 알림 및 확인 대화 상자를 가장 잘 처리하는 방법을 보여줍니다

라이브러리에는 데이터인 '경고 상태'와 '확인 대화상자 상태'의 두 가지 유형이 제공됩니다
경고 또는 대화 상자의 상태와 동작에 대한 설명입니다. \
알림 또는 확인 대화 상자 표시 여부를 제어하는 축소기, 그리고 해당 뷰 수정자인 'alert(_:)'와 'confirmationDialog(_:)'는 바인딩을 넘겨줄 수 있습니다 \
알림 또는 대화 상자를 표시할 수 있도록 알림 또는 대화 상자 도메인에 초점을 맞춘 스토어로 이동합니다
뷰.

이러한 유형을 사용하면 사용자가 상호 작용하는 방식에 대한 전체 테스트 범위를 얻을 수 있다는 이점이 있습니다
"""

@Reducer
struct AlertAndConfirmationDialog {
    @ObservableState
    struct State: Equatable {
      @Presents var alert: AlertState<Action.Alert>?
      @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
      var count = 0
    }
    
    enum Action {
        case alert(PresentationAction<Alert>)
        case alertButtonTapped
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case confirmationDialogButtonTapped
        
        @CasePathable
        enum Alert {
            case incrementButtonTapped
        }
        @CasePathable
        enum ConfirmationDialog {
            case incrementButtonTapped
            case decrementButtonTapped
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.incrementButtonTapped)), .confirmationDialog(.presented(.incrementButtonTapped)):
                state.alert = AlertState { TextState("Incremented!") }
                state.count += 1
                return .none
                
            case .alert:
                return .none
                
            case .alertButtonTapped:
                state.alert = AlertState(
                    title: {
                        TextState("Alert!")
                    },
                    actions: {
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }
                        ButtonState(action: .incrementButtonTapped) {
                            TextState("Increment")
                        }
                    },
                    message: {
                        TextState("This is an alert")
                    }
                )
                return .none
                
            case .confirmationDialog(.presented(.decrementButtonTapped)):
                state.alert = AlertState { TextState("Decremented!") }
                state.count -= 1
                return .none
                
            case .confirmationDialog:
                return .none
                
            case .confirmationDialogButtonTapped:
                state.confirmationDialog = ConfirmationDialogState {
                  TextState("Confirmation dialog")
                } actions: {
                  ButtonState(role: .cancel) {
                    TextState("Cancel")
                  }
                  ButtonState(action: .incrementButtonTapped) {
                    TextState("Increment")
                  }
                  ButtonState(action: .decrementButtonTapped) {
                    TextState("Decrement")
                  }
                } message: {
                  TextState("This is a confirmation dialog.")
                }
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}

struct AlertAndConfirmationDialogView: View {
    @Bindable var store: StoreOf<AlertAndConfirmationDialog>
    
    var body: some View {
        Form {
            Section {
                AboutView(readMe: readMe)
            }
            
            Text("Count: \(store.count)")
            Button("Alert") { store.send(.alertButtonTapped) }
            Button("Confirmation Dialog") { store.send(.confirmationDialogButtonTapped) }
        }
        .navigationTitle("Alerts & Dialogs")
        .alert($store.scope(state: \.alert, action: \.alert))
        .confirmationDialog($store.scope(state: \.confirmationDialog, action: \.confirmationDialog))
    }
}

#Preview {
    NavigationStack {
        AlertAndConfirmationDialogView(
            store: Store(initialState: AlertAndConfirmationDialog.State()) {
                AlertAndConfirmationDialog()
            }
        )
    }
}
