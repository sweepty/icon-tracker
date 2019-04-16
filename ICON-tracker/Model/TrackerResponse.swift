//
//  TrackerResponse.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 01/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation

struct TrackerResponse<T: Decodable>: Decodable {
    var result: String
    var description: String
    var data: [T]
}

struct ChartInfo: Decodable {
    var targetDate: String
    var txCount: Double
}

struct ExchangeInfo: Decodable {
    var marketName: String
    var tradeName: String
    var createDate: String
    var price: String
    var prePrice: String
    var dailyRate: String
}
