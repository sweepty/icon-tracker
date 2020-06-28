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
    var fromAddr: String?
    var toAddr: String?
    var txType: String
    var dataType: String?
    var amount: String
    var fee: String
    var state: Int
    var errorMsg: String?
    var targetContractAddr: String?
    var id: Int?
}

// MARK: - DataClass
struct BlockInfo: Codable {
    let height: Int
    let lastBlock, createDate, peerId: String
    let txCount: Int
    let hash, prevHash: String
    let blockSize: Int
    let amount, fee: String
    let message: String?
}
