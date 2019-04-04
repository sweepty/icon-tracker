//
//  TransactionViewModel.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 04/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TransactionViewModel {
    let trackerService: TrackerService = TrackerService()
    
    let iconService: Requests = Requests()
    // BehaviorRelay는 BehaviorSubject의 wrapper로써 RxSwift 4.0에서 deprecated된 Variable와 개념이 동일하다.
    // 즉, onNext만 사용가능하고, 할당이 해제되면 자동으로 onCompleted() 이벤트를 보낸다. (maybe)
    // error나 completed로 종료되지 않는다.
    // BehaviorSubject는 Subject에 의해 반환된 가장 최근 값과 구독 이후 반환한 값을 가져오기 때문에
    // 앱을 빌드하면 SegementedControl의 값을 변환하지 않았어도 기본값인 0이 있기 때문에 아래처럼 바로 로그가 찍히는 것이다.
    // UISegmentedControl value next(0)
    let segmentedValue = BehaviorRelay(value: 0)
    
    let pageNums = BehaviorRelay(value: 1)
    
    let title: Observable<String>
    
    var currentPrice: Observable<String>
    
    var icxSupply: Observable<String>
    
    var blockItems: Observable<[Block]>
    
    init() {
        self.blockItems = trackerService.getBlockList(page: pageNums.value)
        
        switch UserDefaults.standard.integer(forKey: "network") {
        case 0:
            self.title = Observable.just("Mainnet")
        case 1:
            self.title = Observable.just("Testnet for DApp")
        case 2:
            self.title = Observable.just("Testnet for Exchange")
        default:
            self.title = Observable.just("Mainnet")
        }
        
        self.currentPrice = trackerService.getCurrentExchange()

        self.icxSupply = iconService.getTotalSupply()
    }
    
    
}
