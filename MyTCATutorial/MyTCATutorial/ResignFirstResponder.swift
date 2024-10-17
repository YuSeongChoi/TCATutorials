//
//  ResignFirstResponder.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/17/24.
//

import SwiftUI

extension Binding {
    /// 비활성화하면 SwiftUI가 콘솔에 "AttributeGraph: 사이클 감지"에 대한 오류를 인쇄합니다
    /// 초점이 맞춰진 상태에서 텍스트 필드. 이 해킹으로 인해 모든 필드의 초점이 해제됩니다
    /// 필드를 비활성화할 수 있는 바인딩으로 이동합니다.
    ///
    /// See also: https://stackoverflow.com/a/69653555
    @MainActor
    func resignFirstResponder() -> Self {
        Self(
          get: { self.wrappedValue },
          set: { newValue, transaction in
            UIApplication.shared.sendAction(
              #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
            )
            self.transaction(transaction).wrappedValue = newValue
          }
        )
    }
}
