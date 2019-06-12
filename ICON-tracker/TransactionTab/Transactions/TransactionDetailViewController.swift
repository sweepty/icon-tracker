//
//  TransactionDetailViewController.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 22/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ICONKit

class TransactionDetailViewController: UIViewController {
    
    @IBOutlet weak var txHashLabel: UILabel!
    @IBOutlet weak var blockHeightLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var stepLimit: UILabel!
    @IBOutlet weak var actualStepLabel: UILabel!
    
    @IBOutlet weak var dataView: UIView!
    
    var hashString = String()
    
    let disposeBag = DisposeBag()
    let detailViewModel = TransactionDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
    }
    
    func setupBind() {
        let detailInfo = detailViewModel.detail.share(replay: 1)
        
        detailInfo
            .map { $0.txHash }
            .bind(to: txHashLabel.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map { String($0.blockHeight.hexToBigUInt()!) }
            .bind(to: blockHeightLabel.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map {
                let date = $0.timestamp.hextoDate()!
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.ZZZ"
                return formatter.string(from: date)
            }
            .bind(to: timestampLabel.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map { $0.from }
            .bind(to: fromLabel.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map { $0.to }
            .bind(to: toLabel.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map { String($0.value?.hexToBigUInt() ?? 0) }
            .bind(to: amountLabel.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map { String($0.stepLimit.hexToBigUInt()!) }
            .bind(to: stepLimit.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map { String($0.stepLimit.hexToBigUInt()!) }
            .bind(to: actualStepLabel.rx.text )
            .disposed(by: disposeBag)
        
        detailInfo
            .map { $0.data }
            .subscribe(onNext: { (dataType) in
                if let data = dataType {
                    switch data {
                    case .string(let string):
                        let test = string.prefix0xRemoved()
                        let data = Data(hex: test)
                        
                        // encode data to base64
                        let encodedAsData = data.base64EncodedString(options: .lineLength64Characters)
                        
                        // decode
                        let dataDecoded: Data = Data(base64Encoded: encodedAsData, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                        // data:image/jpeg;base64~~~~~~~~~
                        // 잘됨;
                        guard let str = String(data: dataDecoded, encoding: .utf8) else {
                            return
                        }
                        if str.hasPrefix("data:image/jpeg;base64") {
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.dataView.frame.width, height: self.dataView.frame.height))
                            imageView.image = str.base64ToImage()
                            self.view.addSubview(imageView)
                            imageView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                            imageView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                            
                        } else if str.hasPrefix("data:image/gif;base64") {
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.dataView.frame.width, height: self.dataView.frame.height))
                            imageView.image = str.base64ToImage()
                            self.view.addSubview(imageView)
                            imageView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                            imageView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                            
                        } else {
                            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.dataView.frame.width, height: self.dataView.frame.height))
                            textView.text = str
                            self.dataView.addSubview(textView)
                            textView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                            textView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                        }
                    case .dataInfo(let dataInfo):
                        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.dataView.frame.width, height: self.dataView.frame.height))
                        textView.text = "method: \(dataInfo.method)\nparams: \(dataInfo.params)"
                        self.dataView.addSubview(textView)
                        textView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                        textView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                    }
                } else {
                    let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.dataView.frame.width, height: self.dataView.frame.height))
                    emptyView.backgroundColor = .white
                    self.dataView.addSubview(emptyView)
                    emptyView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                    emptyView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                }
            }).disposed(by: disposeBag)
        
        detailViewModel.hash.onNext(hashString)
    }
}
