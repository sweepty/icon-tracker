//
//  BlockDetailViewModel.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 02/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ICONKit

class BlockDetailViewModel {
    let height: PublishSubject<UInt64>
    
    let blockInfo: PublishSubject<Response.Block>
    let txList: PublishSubject<[Response.Block.ConfirmedTransactionList]>

    let disposeBag = DisposeBag()
    var cache: Response.Block? = nil
    var tmpHeight: PublishSubject<UInt64>
    
    init(iconService: Requests = Requests()) {
        let userDefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        
        self.height = PublishSubject<UInt64>()
        
        self.blockInfo = PublishSubject<Response.Block>()
        self.txList = PublishSubject<[Response.Block.ConfirmedTransactionList]>()
        
        self.tmpHeight = PublishSubject<UInt64>()
        
        height
            .flatMap({ [unowned self] (height) -> Observable<Response.Block> in
            return iconService.getBlockByHeight(network: userDefaultsNetwork, height: height)
                .do(onNext: { (block) in
                    Log.Verbose("캐시에 넣음")
                    self.cache = block
                })
                .catchError({ (error) -> Observable<Response.Block> in
                    self.tmpHeight.onNext(height-1)
                    if let cache = self.cache {
                        Log.Debug("CACHE!")
                        return Observable.just(cache)
                    } else {
                        Log.Debug("EMPTY...")
                        return Observable.empty()
                    }
                })
            }).bind(to: self.blockInfo)
            .disposed(by: disposeBag)
        
        tmpHeight.flatMapLatest { (tmp) -> Observable<UInt64> in
            return Observable.just(tmp)
        }.bind(to: self.height)
        .disposed(by: disposeBag)
        
        blockInfo
            .flatMapLatest { (block) -> Observable<[Response.Block.ConfirmedTransactionList]> in
                return Observable.just(block.confirmedTransactionList)
            }.bind(to: self.txList)
            .disposed(by: disposeBag)
    }
}
