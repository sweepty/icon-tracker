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

class ICON {
    func getNetworklist() -> Driver<[Int]> {
        return Observable.just([0, 1 ,2]).asDriver(onErrorJustReturn: [])
    }
}

class Requests {
    func setNetwork(network: Int) -> ICONService {
        var iconService: ICONService
        switch network {
        case 0:
            iconService = ICONService.init(provider: BaseURL.mainnet.url, nid: BaseURL.mainnet.nid)
        case 1:
            iconService = ICONService.init(provider: BaseURL.testnetforDApps.url, nid: BaseURL.testnetforDApps.nid)
        case 2:
            iconService = ICONService.init(provider: BaseURL.testnetforExchanges.url, nid: BaseURL.testnetforExchanges.nid)
        default:
            iconService = ICONService.init(provider: BaseURL.mainnet.url, nid: BaseURL.mainnet.nid)
        }
        return iconService
    }
    
    func getTotalSupply(network: Int) -> Observable<String> {
        let iconService = setNetwork(network: network)
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
    
    func getTransactionDetail(network: Int, hash: String) -> Observable<[Any]> {
        let iconService = setNetwork(network: network)
        let request = iconService.getTransaction(hash: hash)
        let response = request.execute()
        
        switch response {
        case .success(let value):
            var data = ""
            
            if let dat = value.data {
                switch dat {
                case .string(let str):
                    data = str
                case .dataInfo(let info):
                    var st = #"{ \#n \#t"method": "\#(info.method)" \#n"#
                    if let params = info.params {
                        st += #"\#t"params": {\#n"#
                        for i in params {
                            st += #"\#t\#t"\#(i.key)" : "\#(i.value)"\#n"#
                        }
                        st += "\t} \n}"
                        data = st
                    }
                }
            }

            var arr: [Any] = []
            arr += [value.blockHash, value.blockHeight.hextoInt(), value.signature, value.txHash, value.txIndex, value.timestamp, value.from, value.to, value.stepLimit, value.value ?? "", data]
            
            return Observable.just(arr)
            
        case .failure(let error):
            Log.Error(error)
            return Observable.error(error)
        }
    }
}

class TrackerRequests {
    var provider: URL
    var method: TrackerMethod
    var params: [String : Any]
    
    init(network: Int, method: TrackerMethod, params: [String : Any]) {
        let url: URL

        switch network {
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
        var url = provider.appendingPathComponent(self.method == .getCurrentExchangeList || self.method == .getChartData ? "v0" : "v3")
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
    
    func getCurrentExchange(network: Int) -> Observable<String> {
        let request = TrackerRequests(network: network, method: .getCurrentExchangeList, params: ["codeList": "icxusd"])
        
        return session.rx.data(request: request.createRequest())
            .flatMap({ (value) -> Observable<String> in
                
                let decoded = try decoder.decode(TrackerResponse<ExchangeInfo>.self, from: value)
                let price = decoded.data.first?.price
                
                guard let usdPrice = price, let tmp = Double(usdPrice) else {
                    return Observable.error(ICONTrackerError.unknown)
                }
                let floorPrice = floor(tmp * 1000) / 1000
                let final = String(floorPrice)
                
                return Observable.just(final)
            })
    }
    
    func getChartData(network: Int) -> [ChartInfo] {
        var chartData = [ChartInfo]()
        let semaphore = DispatchSemaphore(value: 0)

        let request = TrackerRequests(network: network, method: .getChartData, params: [:])

        session.dataTask(with: request.createRequest()) { (data, response, error) in
            guard error == nil && data != nil else {
                Log.Error(ICONTrackerError.network)
                return
            }

            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    let decoded = try decoder.decode(TrackerResponse<ChartInfo>.self, from: data)
                    chartData = decoded.data
                    semaphore.signal()
                } catch {
                    Log.Error(ICONTrackerError.parsing)
                    return
                }
            }

        }.resume()
        semaphore.wait()
        return chartData
    }
    
    func getBlockList(network: Int, page: Int) -> Observable<[Block]> {
        let request = TrackerRequests(network: network, method: .getBlockList, params: ["page": page, "count": 25])
        Log.Error("블락 받아옴")
        return session.rx.data(request: request.createRequest())
            .flatMap({ (value) -> Observable<[Block]> in
                
                let jsonVal = try JSONSerialization.jsonObject(with: value, options: .allowFragments) as! [String :Any]
                let dataVal = jsonVal["data"]
                let finalData = try JSONSerialization.data(withJSONObject: dataVal!, options: .prettyPrinted)
                let decoded = try decoder.decode([Block].self, from: finalData)
                
                return Observable.just(decoded)
            })
    }
    
    func getTransactionList(network: Int, page: Int) -> Observable<[TransactionBlock]> {
        let request = TrackerRequests(network: network, method: .getTransactionRecentTx, params: ["page": page, "count": 25])

        return session.rx.data(request: request.createRequest())
            .flatMap({ (value) -> Observable<[TransactionBlock]> in
                let jsonVal = try JSONSerialization.jsonObject(with: value, options: .allowFragments) as! [String :Any]
                let dataVal = jsonVal["data"]
                let finalData = try JSONSerialization.data(withJSONObject: dataVal!, options: .prettyPrinted)
                let decoded = try decoder.decode([TransactionBlock].self, from: finalData)

                return Observable.just(decoded)
            })
    }
    
    func getTransactionDetail(network: Int, hash: String) -> Observable<[Any]> {
        let request = TrackerRequests(network: network, method: .getTransactionDetail, params: ["txHash": hash])
        
        return session.rx.data(request: request.createRequest())
            .flatMap({ (value) -> Observable<[Any]> in
                let decoded = try decoder.decode(TrackerResponseString<TransactionDetail>.self, from: value)
                let finalData = decoded.data
                
                let arr: [Any] = [
                    finalData.txHash,
                    finalData.amount,
                    finalData.dataString ?? "",
                    finalData.height,
                    finalData.toAddr,
                    finalData.fromAddr,
                    finalData.dataType,
                    finalData.status,
                    finalData.stepLimit,
                    finalData.stepPrice,
                    finalData.stepUsedByTxn
                    
                ]
                
                return Observable.just(arr)
            })
    }
}

