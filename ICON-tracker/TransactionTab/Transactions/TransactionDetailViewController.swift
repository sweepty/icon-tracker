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
        
        detailViewModel.hash.onNext(hashString)
    }
}
