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

public class TransactionViewModel {
    // BehaviorRelay는 BehaviorSubject의 wrapper로써 RxSwift 4.0에서 deprecated된 Variable와 개념이 동일하다.
    // 즉, onNext만 사용가능하고, 할당이 해제되면 자동으로 onCompleted() 이벤트를 보낸다. (maybe)
    // error나 completed로 종료되지 않는다.
    // BehaviorSubject는 Subject에 의해 반환된 가장 최근 값과 구독 이후 반환한 값을 가져오기 때문에
    // 앱을 빌드하면 SegementedControl의 값을 변환하지 않았어도 기본값인 0이 있기 때문에 아래처럼 바로 로그가 찍히는 것이다.
    // UISegmentedControl value next(0)
    let segmentedValue = BehaviorRelay(value: 0)
    
    let pageNums: AnyObserver<Int>
    
    var title: Observable<String>
    
    let setCurrentNetwork: AnyObserver<Int>
    
    let reload: AnyObserver<Void>
    
    let currentPrice: Observable<String>
    
    let icxSupply: Observable<String>
    
    let blockItems: Observable<[Block]>
    
    init(trackerService: TrackerService = TrackerService(), iconService: Requests = Requests()) {
        let _reload = BehaviorSubject<Void>(value: ())
        self.reload = _reload.asObserver()
        
        let userDefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        let _currentNetwork = BehaviorSubject<Int>(value: userDefaultsNetwork)
        
        self.setCurrentNetwork = _currentNetwork.asObserver()
        
        self.title = _currentNetwork.asObservable().map {
            switch $0 {
            case 0:
                return "Mainnet"
            case 1:
                return "Testnet for DApps"
            case 2:
                return "Testnet for Exchanges"
            default:
                return "Mainnet"
            }
        }
        
        self.currentPrice = Observable.combineLatest( _reload, _currentNetwork ) { _, network in network }
            .flatMapLatest { network in
                trackerService.getCurrentExchange(network: network)
        }
        
        self.icxSupply = Observable.combineLatest( _reload, _currentNetwork ) { _, network in network }
            .flatMapLatest { network in
                iconService.getTotalSupply(network: network)
            }
        
        let _pageNums = BehaviorSubject<Int>(value: 1)
        self.pageNums = _pageNums.asObserver()
        
        self.blockItems = Observable.combineLatest( _reload, _currentNetwork, _pageNums )
//        { _, network, page in network, page }
            .flatMapLatest { _, network, page in
                trackerService.getBlockList(network: network, page: page)
        }
    }
}

public let viewModel = TransactionViewModel()
