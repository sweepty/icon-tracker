//
//  TransactionDetailViewModel.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 22/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ICONKit

class TransactionDetailViewModel {
    let hash: PublishSubject<String>
    let detail: Observable<[Any]>
    
    init(iconRequest: Requests = Requests()) {
        let userDefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        self.hash = PublishSubject<String>()
        
        self.detail = hash.flatMapLatest({ (hash) -> Observable<[Any]>  in
            return iconRequest.getTransactionDetail(network: userDefaultsNetwork, hash: hash)
        })
    }
}
