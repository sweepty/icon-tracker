//
//  Response.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 02/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation

struct Block: Decodable {
    var height: Int
    var createDate: String
    var txCount: Int
    var hash: String
    var amount: String
    var fee: String
}

struct TransactionBlock: Decodable {
    var txHash: String
    var height: Int
    var createDate: String
    var fromAddr: String
    var toAddr: String
    var txType: String
    var dataType: String
    var amount: String
    var fee: String
    var state: Int
    var targetContractAddr: String?
    var id: Int
}
