//
//  Theme.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 09/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxTheme

protocol Theme {
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
}

struct LightTheme: Theme {
    let backgroundColor = UIColor.white
    let textColor = UIColor.black
}

struct DarkTheme: Theme {
    let backgroundColor = UIColor.black
    let textColor = UIColor.white
}

enum ThemeType: ThemeProvider {
    case light, dark
    var associatedObject: Theme {
        switch self {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        }
    }
}

let themeService = UserDefaults.standard.bool(forKey: "darkmode") ?
    ThemeType.service(initial: .dark) : ThemeType.service(initial: .light)
