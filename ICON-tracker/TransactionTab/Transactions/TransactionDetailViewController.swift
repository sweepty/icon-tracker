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
            .subscribe(onNext: { (data) in
                if let data = data {
                    switch data {
                    case .call(let call):
                        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.dataView.bounds.width, height: self.dataView.bounds.height))
                        textView.font = .systemFont(ofSize: 15)
                        textView.text = "\"method\": \"\(call.method)\"\n"
                        if let params = call.params {
                            textView.text.append(contentsOf: "\n\"params\":\n")
                            for i in params {
                                textView.text.append(contentsOf: "\t\"\(i.key)\": \"\(i.value)\"\n")
                            }
                        }
                        self.dataView.addSubview(textView)
                        textView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                        textView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                        
                    case .deploy(let deploy):
                        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.dataView.bounds.width, height: self.dataView.bounds.height))
                        textView.font = .systemFont(ofSize: 15)
                        textView.text = "\"contentType\": \"\(deploy.contentType)\"\n\"content\": \"\(deploy.content)\"\n\"params\": \"\(deploy.params!)\""
                        self.dataView.addSubview(textView)
                        textView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                        textView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                    case .message(let message):
                        let test = message.prefix0xRemoved()
                        let data = Data(hex: test)
                        
                        // encode data to base64
                        let encodedAsData = data.base64EncodedString(options: .lineLength64Characters)
                        
                        // decode
                        let dataDecoded: Data = Data(base64Encoded: encodedAsData, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                        guard let str = String(data: dataDecoded, encoding: .utf8) else {
                            return
                        }
                        if str.hasPrefix("data:image/jpeg;base64") {
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.dataView.bounds.width, height: self.dataView.bounds.height))
                            imageView.image = str.base64ToImage()
                            self.dataView.addSubview(imageView)
                            imageView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                            imageView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                            
                        } else if str.hasPrefix("data:image/gif;base64") {
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.dataView.bounds.width, height: self.dataView.bounds.height))
                            imageView.image = str.base64ToImage()
                            self.view.addSubview(imageView)
                            imageView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                            imageView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                            
                        } else {
                            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.dataView.frame.width, height: self.dataView.frame.height))
                            textView.font = .systemFont(ofSize: 15)
                            textView.text = str
                            self.dataView.addSubview(textView)
                            textView.topAnchor.constraint(equalTo: self.dataView.topAnchor).isActive = true
                            textView.leadingAnchor.constraint(equalTo: self.dataView.leadingAnchor).isActive = true
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        detailViewModel.hash.onNext(hashString)
    }
}
