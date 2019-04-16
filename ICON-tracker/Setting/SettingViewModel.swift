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
    // inputs
    let darkMode: AnyObserver<Bool>
    
    // outputs
    let settingList: Observable<[String]>
    let darkModeValue: Observable<Bool>

    init() {
        self.settingList = Observable.just(["네트워크 설정", "Dark mode"])
        
        let userdefaultsDarkMode = UserDefaults.standard.bool(forKey: "darkmode")
        let _darkMode = BehaviorSubject<Bool>(value: userdefaultsDarkMode)
        self.darkMode = _darkMode.asObserver()
        self.darkModeValue = _darkMode.asObservable()
    }
}
