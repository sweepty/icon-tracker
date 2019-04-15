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
    
    let segmentedValue = BehaviorRelay(value: 0)
    
    let title: Driver<String>
    
    let setCurrentNetwork: AnyObserver<Int>
    
    let reload = BehaviorSubject<Void>(value: ())
    
    let currentPrice: Driver<String>
    
    let icxSupply: Driver<String>
    
    let blockItems: BehaviorRelay<[Block]> = BehaviorRelay<[Block]>(value: [])
    
    let nextPageTrigger: PublishSubject<Void>
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    
    let error = PublishSubject<Swift.Error>()
    
    private var pageCount: Int = 1
    
    var isEnd: Bool = false
    
    let disposeBag = DisposeBag()
    
    init(trackerService: TrackerService = TrackerService(), iconService: Requests = Requests()) {
        
        let userDefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        let _currentNetwork = BehaviorSubject<Int>(value: userDefaultsNetwork)
        
        self.setCurrentNetwork = _currentNetwork.asObserver()
        
        self.title = _currentNetwork.asDriver(onErrorJustReturn: 0).map {
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
        
        self.currentPrice = Observable.combineLatest( self.reload, _currentNetwork ) { _, network in network }
            .flatMapLatest { network in
                trackerService.getCurrentExchange(network: network)
            }.asDriver(onErrorJustReturn: "error")
        
        self.icxSupply = Observable.combineLatest( self.reload, _currentNetwork ) { _, network in network }
            .flatMapLatest { network in
                iconService.getTotalSupply(network: network)
            }.asDriver(onErrorJustReturn: "error")
        
        self.nextPageTrigger = PublishSubject<Void>()
        
        let loadingObservable = self.isLoading.share(replay: 1)
        
        let refreshRequest = loadingObservable.asObservable()
            .sample(reload)
            .flatMap { loading -> Observable<Int> in
                if loading || self.isEnd {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.pageCount = 1
                        print("첫번째 리로드")
                        observer.onNext(1)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
            }
        
        let nextPageRequest = loadingObservable.asObservable()
            .sample(nextPageTrigger)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { [unowned self] observer in
                        self.pageCount += 1
                        print(self.pageCount)
                        observer.onNext(self.pageCount)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
            }
        
        let request = Observable.merge(refreshRequest, nextPageRequest)
            .share(replay: 1)
        
        let response = request.flatMapLatest { page in
                trackerService.getBlockList(network: userDefaultsNetwork, page: page)
            }
            .share(replay: 1)
        
        Observable
            .combineLatest(reload.asObservable(), request, response, blockItems.asObservable()) { _, request, response, blocks in
                self.isEnd = response.count < 30
                
                return self.pageCount == 1 ? response : blocks + response
            }
            .sample(response)
            .bind(to: blockItems)
            .disposed(by: disposeBag)
        
        Observable
            .merge(request.map{ _ in true },
                   response.map { _ in false },
                   error.map { _ in false })
            .bind(to: isLoading)
            .disposed(by: disposeBag)
    }
}

public let viewModel = TransactionViewModel()
