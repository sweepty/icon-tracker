//
//  Utils.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 01/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    /// Convert loop to ICX
    func convertToICX() -> BigUInt {
        return self / BigUInt(1000000000000000000)
    }
}
