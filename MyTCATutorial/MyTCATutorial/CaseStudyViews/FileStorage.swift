//
//  FileStorage.swift
//  MyTCATutorial
//
//  Created by YuSeongChoi on 10/28/24.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
이 화면은 합성 가능한 여러 개의 독립 화면이 상태를 공유할 수 있는 방법을 보여줍니다
파일 스토리지를 통한 아키텍처. 각 탭은 자체 상태를 관리하며
별도의 모듈에 포함될 수 있지만 한 탭의 변경 사항은 다른 탭에 즉시 반영되며 \
모든 변경 사항은 디스크에 지속됩니다.

이 탭에는 증가 및 감소할 수 있는 카운트 값으로 구성된 자체 상태가 있습니다, \
또한 현재 카운트가 소수인지 물어볼 때 설정되는 경고 값도 포함됩니다.

내부적으로도 최소 및 최대 수 등 다양한 통계를 추적하고 있습니다
발생한 카운트 이벤트의 수입니다. 해당 상태는 다른 탭에서 볼 수 있으며 통계는 \
는 다른 탭에서 재설정할 수 있습니다.

  This screen demonstrates how multiple independent screens can share state in the Composable \
  Architecture through file storage. Each tab manages its own state, and \
  could be in separate modules, but changes in one tab are immediately reflected in the other, and \
  all changes are persisted to disk.

  This tab has its own state, consisting of a count value that can be incremented and decremented, \
  as well as an alert value that is set when asking if the current count is prime.

  Internally, it is also keeping track of various stats, such as min and max counts and total \
  number of count events that occurred. Those states are viewable in the other tab, and the stats \
  can be reset from the other tab.
"""

