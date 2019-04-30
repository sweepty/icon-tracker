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

class TransactionDetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var dataTextView: UITextView!
    
    private let detailViewModel = TransactionDetailViewModel()
    
    var hashString: String = String()
    
    let disposeBag = DisposeBag()
    
    let titleList = ["blockHash", "height", "signature", "txHash", "timestamp", "from", "to", "stepLimit", "value", "data"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataTextView.delegate = self
        self.dataTextView.isEditable = false
        
        setUpBinding()
    }
    
    func setUpBinding() {
        let detailShare = detailViewModel.detail.observeOn(MainScheduler.instance).share(replay: 1)
        
        detailShare
            .observeOn(MainScheduler.instance)
            .bind(to: self.tableView.rx.items(cellIdentifier: "cell1", cellType: UITableViewCell.self)) { (row, element, cell) in

                if row == self.titleList.count - 1 {
                    let el = element as? String
                    
                    if let el = el, el.hasPrefix("0x") {
                        guard let hex = Data(hexString: el.prefix0xRemoved()), let str = String(data: hex, encoding: .utf8) else {
                            self.dataTextView.text = ""
                            return
                        }
                        self.dataTextView.text = str
                        
                    } else {
                        self.dataTextView.text = el
                    }
                    
                } else {
                    cell.textLabel?.text = self.titleList[row]
                    cell.detailTextLabel?.text = "\(element)"
                }
                
            }
            .disposed(by: disposeBag)
        
        // 1
//        Observable<String>.just(hashString)
//            .bind(to: detailViewModel.hash)
//            .disposed(by: disposeBag)
        
        // 2
//        Observable<String>.just(hashString)
//            .subscribe(detailViewModel.hash)
//            .disposed(by: disposeBag)
        // 3
        detailViewModel.hash.onNext(hashString)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
