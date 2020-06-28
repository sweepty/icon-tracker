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
import Charts

public class TransactionViewModel {
    
    let segmentedValue = BehaviorRelay(value: 0)
    
    let title: Driver<String>
    
    let setCurrentNetwork: BehaviorSubject<Int>
    
    let reload = BehaviorSubject<Void>(value: ())
    
    let tReload = BehaviorSubject<Void>(value: ())
    
    let currentPrice: Driver<String>
    
    let icxSupply: Driver<String>
    
    let blockItems: BehaviorRelay<[Block]> = BehaviorRelay<[Block]>(value: [])
    
    let transactionItems: BehaviorRelay<[TransactionBlock]> = BehaviorRelay<[TransactionBlock]>(value: [])
    
    let nextPageTrigger: PublishSubject<Void>
    
    let tNextPageTrigger: PublishSubject<Void>
    
    let isLoading = BehaviorSubject<Bool>(value: false)
    
    let tisLoading = BehaviorSubject<Bool>(value: false)
    
    let error = PublishSubject<Swift.Error>()
    
    private var pageCount: Int = 1
    
    private var tPageCount: Int = 1
    
    let values: BehaviorRelay<[ChartInfo]>
    
    let disposeBag = DisposeBag()
    
    init(trackerService: TrackerService = TrackerService(), iconService: Requests = Requests()) {
        
        let userDefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        
        self.setCurrentNetwork = BehaviorSubject<Int>(value: userDefaultsNetwork)
        
        self.values = BehaviorRelay<[ChartInfo]>(value: trackerService.getChartData(network: userDefaultsNetwork))
        
        Observable.combineLatest(self.reload, self.setCurrentNetwork, self.tReload) { _, network, _ in network }
            .flatMapLatest { network in
                return Observable.just(trackerService.getChartData(network: network))
            }
            .bind(to: values)
            .disposed(by: disposeBag)
        
        self.title = setCurrentNetwork.asDriver(onErrorJustReturn: 0).map {
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
        
        self.currentPrice = Observable.combineLatest( reload, setCurrentNetwork )
            .flatMapLatest { _, network in
                trackerService.getCurrentExchange(network: network)
            }.asDriver(onErrorJustReturn: "error")
        
        self.icxSupply = Observable.combineLatest( reload, setCurrentNetwork )
            .flatMapLatest { _, network in
                iconService.getTotalSupply(network: network)
            }.asDriver(onErrorJustReturn: "error")
        
        self.nextPageTrigger = PublishSubject<Void>()
        
        self.tNextPageTrigger = PublishSubject<Void>()
        
        let loadingObservable = self.isLoading.share(replay: 1)
        
        let refreshRequest = loadingObservable.asObservable()
            .sample(reload)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.pageCount = 1
                        observer.onNext(1)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
        }
        
        let changeNetworkRequest = loadingObservable.asObservable()
            .sample(setCurrentNetwork)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.pageCount = 1
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
        
        let request = Observable.merge(refreshRequest, nextPageRequest, changeNetworkRequest)
            .share(replay: 1)
        
        let response = Observable.combineLatest(request, setCurrentNetwork.asObservable())
            .flatMapLatest { page, network in
                trackerService.getBlockList(network: network, page: page)
            }.share(replay: 1)
        
        Observable
            .combineLatest(reload.asObservable(), request, response, blockItems.asObservable()) { _, request, response, blocks in
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
        
        // ----------------- transactions -----------------
        let tloadingObservable = self.tisLoading.share(replay: 1)
        
        let transactionRefreshRequest = tloadingObservable.asObservable()
            .sample(tReload)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.tPageCount = 1
                        observer.onNext(1)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
        }
        
        let transactionChangeNetworkRequest = tloadingObservable.asObservable()
            .sample(setCurrentNetwork)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { observer in
                        self.tPageCount = 1
                        observer.onNext(1)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
        }
        
        let transactionNextPageRequest = tloadingObservable.asObservable()
            .sample(tNextPageTrigger)
            .flatMap { loading -> Observable<Int> in
                if loading {
                    return Observable.empty()
                } else {
                    return Observable<Int>.create { [unowned self] observer in
                        self.tPageCount += 1
                        print(self.tPageCount)
                        observer.onNext(self.tPageCount)
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
        }
        
        let transactionRequest = Observable.merge(transactionRefreshRequest, transactionNextPageRequest, transactionChangeNetworkRequest)
            .share(replay: 1)
        
        let transactionResponse = Observable.combineLatest(transactionRequest, setCurrentNetwork.asObservable())
            .flatMapLatest { page, network in
                trackerService.getTransactionList(network: network, page: page)
            }
            .share(replay: 1)
        
        Observable
            .combineLatest(tReload.asObservable(), transactionRequest, transactionResponse, transactionItems.asObservable()) { _, request, response, transactions in
                return self.tPageCount == 1 ? response : transactions + response
            }
            .sample(transactionResponse)
            .bind(to: transactionItems)
            .disposed(by: disposeBag)
        
        Observable
            .merge(transactionRequest.map{ _ in true },
                   transactionResponse.map { _ in false },
                   error.map { _ in false })
            .bind(to: tisLoading)
            .disposed(by: disposeBag)
        
        
    }
}

public let viewModel = TransactionViewModel()
