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
    
    var hashString: String = ""
    
    let disposeBag = DisposeBag()
    
    let titleList = ["blockHash", "height", "signature", "txHash", "txIndex", "timestamp", "from", "to", "stepLimit", "value", "data"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataTextView.delegate = self
        self.dataTextView.isEditable = false
//        self.dataTextView.
        
        setUpBinding()
        
    }
    
    func setUpBinding() {
        let detailShare = detailViewModel.detail.observeOn(MainScheduler.instance).share(replay: 1)
        
        detailShare
            .observeOn(MainScheduler.instance)
            .bind(to: self.tableView.rx.items(cellIdentifier: "cell1", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = self.titleList[row]
                cell.detailTextLabel?.text = "\(element)"
                
                if row == self.titleList.count - 1 {
//                    self.dataTextView.text = "\(element)"
                    self.dataTextView.attributedText = NSAttributedString(string: "\(element)")
//                    self.dat
                }
            }
            .disposed(by: disposeBag)
        
//        detailShare
        

        // hash 넘겨 받아서 viewModel에 전달
        Observable<String>.just(hashString)
            .bind(to: detailViewModel.hash)
            .disposed(by: disposeBag)
        
        
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

extension TransactionDetailViewController: UITableViewDelegate {
    
}
