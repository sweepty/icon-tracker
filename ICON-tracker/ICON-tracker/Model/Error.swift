//
//  Error.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 04/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation

enum ICONTrackerError: Error {
    case parsing
    case unknown
}

extension ICONTrackerError {
    var description: String {
        switch self {
        case .parsing:
            return "🔥Parsing ERROR"
        default:
            return "🤔 Unknwon ERROR"
        }
    }
}
