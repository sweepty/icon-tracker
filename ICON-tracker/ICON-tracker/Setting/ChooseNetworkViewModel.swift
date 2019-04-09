//
//  ChooseNetworkViewModel.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 05/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChooseNetworkViewModel {
    // inputs
    let selectNetwork: AnyObserver<Int>
    
    // outputs
    let networks: Observable<[Int]>
    let didSelectNetwork: Observable<Int>
    
    init(icon: ICON = ICON()) {
        let _selectNetwork = PublishSubject<Int>()
        self.selectNetwork = _selectNetwork.asObserver()
        self.didSelectNetwork = _selectNetwork.asObservable()
        self.networks = icon.getNetworklist()
    }
}
