//
//  URL.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 29/03/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation

enum BaseURL {
    case mainnet
    case testnetforDApps
    case testnetforExchanges
}

extension BaseURL {
    var url: String {
        switch self {
        case .mainnet:
            return "https://ctz.solidwallet.io/api/v3"
        case .testnetforDApps:
            return "https://bicon.net.solidwallet.io/api/v3"
        case .testnetforExchanges:
            return "https://test-ctz.solidwallet.io/api/v3"
        }

    }
    var tracker: String {
        switch self {
        case .mainnet:
            return "https://tracker.icon.foundation"
        case .testnetforDApps:
            return "https://bicon.tracker.solidwallet.io"
        case .testnetforExchanges:
            return "https://trackerdev.icon.foundation"
        }
    }
    var nid: String {
        switch self {
        case .mainnet:
            return "0x1"
        case .testnetforDApps:
            return "0x3"
        case .testnetforExchanges:
            return "0x2"
        }
    }
}

// tracker API
enum TrackerMethod: String {
    // current exchange
    case getCurrentExchangeList = "/exchange/currentExchangeList"
    // address
    case getAddressList = "/address/list"
    // contract
    case getContractList = "/contract/list"
    // block 가져오기
    case getBlockList = "/block/list"
    // transaction recent tx
    case getTransactionRecentTx = "/transaction/recentTx"
    // transaction internal tx
    case getTransactionInternalTxList = "/transaction/internalTxList"
    // token
    case getTokenList = "/token/list"
    // token transaction list
    case getTokenTxList = "/token/txList"
}

var decoder: JSONDecoder {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
}
