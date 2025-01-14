//
//  02-SharedStateFileStorage.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 1/14/25.
//

import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates how multiple independent screens can share state in the Composable \
  Architecture through file storage. Each tab manages its own state, and \
  could be in separate modules, but changes in one tab are immediately reflected in the other, and \
  all changes are persisted to disk.

  This tab has its own state, consisting of a count value that can be incremented and decremented, \
  as well as an alert value that is set when asking if the current count is prime.

  Internally, it is also keeping track of various stats, such as min and max counts and total \
  number of count events that occurred. Those states are viewable in the other tab, and the stats \
  can be reset from the other tab.
  
  이 화면은 여러 독립 화면이 Composable에서 상태를 공유할 수 있는 방법을 보여줍니다
  파일 저장을 통한 아키텍처. 각 탭은 자체 상태를 관리합니다
  별도의 모듈에 포함될 수 있지만, 한 탭의 변경 사항은 즉시 다른 탭에 반영됩니다
  모든 변경 사항은 디스크에 지속됩니다.

  이 탭에는 증가 및 감소할 수 있는 카운트 값으로 구성된 자체 상태가 있습니다
  현재 카운트가 소수인지 물어볼 때 설정되는 경고 값도 포함됩니다.

  내부적으로는 최소 및 최대 개수, 총합 등 다양한 통계를 추적하고 있습니다
  발생한 카운트 이벤트의 수. 해당 상태는 다른 탭에서 볼 수 있으며, 통계는 다른 탭에서 재설정할 수 있습니다.
  """

@Reducer
struct SharedStateFileStorage {
    enum Tab { case counter, profile }
    
    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.counter
    }
}

extension SharedStateFileStorage {
    @Reducer
    struct CounterTab {
        @ObservableState
        struct State: Equatable {
            @Presents var alert: AlertState<Action.Alert>?
        }
        
        enum Action {
            
            enum Alert: Equatable {}
        }
    }
}

struct Stats: Codable, Hashable {
    private(set) var count = 0
    private(set) var maxCount = 0
    private(set) var minCount = 0
    private(set) var numberOfCounts = 0
    
    mutating func increment() {
        count += 1
        numberOfCounts += 1
        maxCount = max(maxCount, count)
    }
    
    mutating func decrement() {
        count -= 1
        numberOfCounts += 1
        minCount = min(minCount, count)
    }
}

extension SharedKey where Self == FileStorageKey<Stats> {
    fileprivate static var stats: Self {
        fileStorage(.documentsDirectory.appending(component: "stats.json"))
    }
}
