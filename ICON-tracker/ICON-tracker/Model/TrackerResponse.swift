//
//  TrackerResponse.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 01/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation

struct ExchangeResponse: Decodable {
    var result: String
    var description: String
    var data: [DataInfo]
    
    struct DataInfo: Decodable {
        var marketName: String
        var tradeName: String
        var createDate: String
        var price: String
        var prePrice: String
        var dailyRate: String
    }
}

