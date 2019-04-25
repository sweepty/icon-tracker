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

extension String {
    /// Convert hex String to Int
    public func hextoInt() -> Int {
        return Int(self.prefix0xRemoved(), radix: 16) ?? 0
    }
    
    /// Convert hex String to Date
    public func hextoDate() -> Date? {
        guard let sub = Int(self.prefix0xRemoved(), radix: 16) else {
            return nil
        }
        return Date(timeIntervalSince1970: Double(sub) / 1000000.0)
    }
}

extension Data {
    // hex String to data
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
