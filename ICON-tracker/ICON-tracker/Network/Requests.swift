//
//  Requests.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 29/03/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import ICONKit
import BigInt
import RxSwift
import RxCocoa

class Requests {
    private var iconService: ICONService
    
    init() {
        switch UserDefaults.standard.integer(forKey: "network") {
        case 0:
            iconService = ICONService.init(provider: BaseURL.mainnet.url, nid: BaseURL.mainnet.nid)
        case 1:
            iconService = ICONService.init(provider: BaseURL.testnetforDApps.url, nid: BaseURL.testnetforDApps.nid)
        case 2:
            iconService = ICONService.init(provider: BaseURL.testnetforExchanges.url, nid: BaseURL.testnetforExchanges.nid)
        default:
            iconService = ICONService.init(provider: BaseURL.mainnet.url, nid: BaseURL.mainnet.nid)
        }
    }
    
    func getTotalSupply() -> Observable<String> {
        let request = iconService.getTotalSupply()
        let response = request.execute()
        
        switch response {
        case .success(var value):
            value = value.convertToICX()
            return Observable.just("\(value)")
        case .failure(let error):
            Log.Error(error)
            return Observable.just("error")
        }
    }
}

class TrackerRequests {
    var provider: URL
    var method: TrackerMethod
    var params: [String : Any]
    
    init(method: TrackerMethod, params: [String : Any]) {
        let url: URL
        switch UserDefaults.standard.integer(forKey: "network") {
        case 0:
            url = URL(string: BaseURL.mainnet.tracker)!
        case 1:
            url = URL(string: BaseURL.testnetforDApps.tracker)!
        case 2:
            url = URL(string: BaseURL.testnetforExchanges.tracker)!
        default:
            url = URL(string: BaseURL.mainnet.tracker)!
        }
        self.provider = url
        self.method = method
        self.params = params
    }
    
    func createRequest() -> URLRequest {
        var url = provider.appendingPathComponent(self.method == .getCurrentExchangeList ? "v0" : "v3")
        url = url.appendingPathComponent(method.rawValue)
        
        var urlComponent = URLComponents(string: url.absoluteString)
        
        var queries = [URLQueryItem]()
        
        for item in params {
            queries.append(URLQueryItem(name: item.key, value: String("\(item.value)")))
        }
        
        urlComponent!.queryItems = queries
        
        var request = URLRequest(url: urlComponent!.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.httpMethod = "GET"
        
        return request
    }
}

class TrackerService {
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func getCurrentExchange() -> Observable<String> {
        let request = TrackerRequests(method: .getCurrentExchangeList, params: ["codeList": "icxusd"])
        
        return session.rx.data(request: request.createRequest())
            .flatMap({ (value) -> Observable<String> in
                
                let decoded = try decoder.decode(ExchangeResponse.self, from: value)
                let price = decoded.data.first?.price
                
                guard let usdPrice = price, let tmp = Double(usdPrice) else {
                    return Observable.just("error")
                }
                let floorPrice = floor(tmp * 1000) / 1000
                let final = String(floorPrice)
                
                return Observable.just(final)
            })
    }
    
    func getBlockList(page: Int) -> Observable<[Block]> {
        let request = TrackerRequests(method: .getBlockList, params: ["page": page, "count": 25])
        
        return session.rx.data(request: request.createRequest())
            .flatMap({ (value) -> Observable<[Block]> in
                
                let jsonVal = try JSONSerialization.jsonObject(with: value, options: .allowFragments) as! [String :Any]
                let dataVal = jsonVal["data"]
                let finalData = try JSONSerialization.data(withJSONObject: dataVal!, options: .prettyPrinted)
                let decoded = try decoder.decode([Block].self, from: finalData)
                
                return Observable.just(decoded)
            })
    }
    
    func getTransactionList(page: Int) -> Observable<[TransactionBlock]> {
        let request = TrackerRequests(method: .getTransactionRecentTx, params: ["page": page, "count": 25])
        
        return session.rx.data(request: request.createRequest())
            .flatMap({ (value) -> Observable<[TransactionBlock]> in
                let jsonVal = try JSONSerialization.jsonObject(with: value, options: .allowFragments) as! [String :Any]
                let dataVal = jsonVal["data"]
                let finalData = try JSONSerialization.data(withJSONObject: dataVal!, options: .prettyPrinted)
                let decoded = try decoder.decode([TransactionBlock].self, from: finalData)
                
                return Observable.just(decoded)
            })
    }
    
}

