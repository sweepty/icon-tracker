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
    let blockInfo: Observable<Response.Block>
    
    let txList: PublishSubject<[Response.Block.ConfirmedTransactionList]>

    let disposeBag = DisposeBag()
    
    init(iconService: Requests = Requests()) {
        let userDefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        
        self.height = PublishSubject<UInt64>()
        
        self.txList = PublishSubject<[Response.Block.ConfirmedTransactionList]>()
        
        self.blockInfo = height.flatMapLatest({ (height) -> Observable<Response.Block>  in
            return iconService.getBlockByHeight(network: userDefaultsNetwork, height: height)
        })
    }
}
