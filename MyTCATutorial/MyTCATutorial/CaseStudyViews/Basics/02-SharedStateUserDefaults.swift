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
