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
    
    public func hextoDouble() -> Double {
        let tmp = self.hextoInt()
        
        return Double(tmp) / 65535
    }
    
    /// Convert hex String to Date
    public func hextoDate() -> Date? {
        guard let sub = Int(self.prefix0xRemoved(), radix: 16) else {
            return nil
        }
        return Date(timeIntervalSince1970: Double(sub) / 1000000.0)
    }
    
    public func toDate() -> Date {
        let dateformatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            return formatter
        }()
        
        let date = dateformatter.date(from: self)
        return date!
    }
    
    public func calculateAge() -> String {
        let date = self.toDate()
        let now = Date()
        do {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
            formatter.unitsStyle = .full
            // short 1 min
            // spellOut twenty-eight seconds
            // full 6 minutes
            formatter.maximumUnitCount = 1
            let daysString = formatter.string(from: date, to: now)
            return daysString!
        }
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
extension String {
    // convert base64
    public func base64ToImage() -> UIImage? {
        if let url = URL(string: self), let data = try? Data(contentsOf: url),let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}

extension Double {
    public func toDateString() -> String {
        let date = Date(timeIntervalSince1970: self / 1000000.0)
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale.current
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZ"
        
        let value = dateformatter.string(from: date)
        return value
    }
    
    public func calculateAge() -> String {
        let date = Date(timeIntervalSince1970: self / 1000000.0)
        let now = Date()
        do {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
            formatter.unitsStyle = .short
            formatter.maximumUnitCount = 1
            let daysString = formatter.string(from: date, to: now)
            return daysString!
        }
    }
}

@IBDesignable
class CircleView: UIView {
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(self.layer.bounds.width/2)
        }
    }
}
