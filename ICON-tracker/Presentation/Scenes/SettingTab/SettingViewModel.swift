//
//  SettingViewModel.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 09/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel {
    // outputs
    let settingList: Observable<[String]>

    init() {
        self.settingList = Observable.just(["네트워크 설정", "Dark mode", "오픈소스 라이센스"])
    }
}
