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
    
    let blockInfo: PublishSubject<BlockInfo>
    let txList: PublishSubject<[Response.Block.ConfirmedTransactionList]>

    let disposeBag = DisposeBag()
    var cache: BlockInfo? = nil
    var tmpHeight: PublishSubject<UInt64>
    
    init(iconService: Requests = Requests()) {
        let userDefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        
        self.height = PublishSubject<UInt64>()
        
        self.blockInfo = PublishSubject<BlockInfo>()
        self.txList = PublishSubject<[Response.Block.ConfirmedTransactionList]>()
        
        self.tmpHeight = PublishSubject<UInt64>()
        
        height
            .flatMap({ (height) -> Observable<BlockInfo> in
                let block = TrackerService().getBlockInfo(network: userDefaultsNetwork, height: height)
                print(block)
                return block
            }).bind(to: self.blockInfo)
            .disposed(by: disposeBag)
        
        tmpHeight.flatMapLatest { (tmp) -> Observable<UInt64> in
            return Observable.just(tmp)
        }.bind(to: self.height)
        .disposed(by: disposeBag)
        
//        blockInfo
//            .flatMapLatest { (block) -> Observable<[Response.Block.ConfirmedTransactionList]> in
//                return Observable.just(block.confirmedTransactionList)
//            }.bind(to: self.txList)
//            .disposed(by: disposeBag)
    }
}
