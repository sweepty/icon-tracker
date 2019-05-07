//
//  BlockDetailViewController.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 02/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ICONKit
import BigInt
import RxDataSources

class BlockDetailViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var blockView: UIView!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var peerIdLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
//    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var txfeeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let blockViewModel = BlockDetailViewModel()
    
    var disposeBag = DisposeBag()
    
    var height = UInt64()
    
    var info = [Response.Block]()
    var txList = [Response.Block.ConfirmedTransactionList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        tableView.rowHeight = 130
        
        setupBind()
    }
    
    func setupBind() {
        blockViewModel.height
            .subscribe(onNext: { (x) in
                print("높이 \(x)")
            })
            .disposed(by: disposeBag)
        
        prevButton.rx.controlEvent(.touchUpInside)
            .subscribe { (x) in
                self.height -= 1
                self.blockViewModel.height.onNext(self.height)
        }.disposed(by: disposeBag)
        
        nextButton.rx.controlEvent(.touchUpInside)
            .subscribe { (x) in
                self.height += 1
                self.blockViewModel.height.onNext(self.height)
        }.disposed(by: disposeBag)
        
        let blockInfo = blockViewModel.blockInfo.observeOn(MainScheduler.instance).share(replay: 1)
        
        blockInfo
            .subscribe(onNext: { (blockInfo) in
                self.info.removeAll()
                self.info.append(blockInfo)
                
                self.txList.removeAll()
                self.txList = blockInfo.confirmedTransactionList
                
                self.blockViewModel.txList.onNext(self.txList)
                
                let firstBlock = self.info.first
                self.hashLabel.text = firstBlock?.blockHash
                self.peerIdLabel.text = firstBlock?.peerId
                
                var amount: BigUInt = BigUInt()
                var fee: Double = Double()
                if let list = firstBlock?.confirmedTransactionList {
                    for i in list {
                        if let amountValue = i.value {
                            amount += amountValue.hexToBigUInt()!
                        }
                        if let feeValue = i.fee {
                            fee += feeValue.hextoDouble()
                        }
                    }
                }
                self.amountLabel.text = "\(amount)"
                self.timestampLabel.text = firstBlock?.timeStamp.toDateString()
                self.txfeeLabel.text = "\(fee)"
                
                
            })
            .disposed(by: disposeBag)
        
        let heightModel = blockViewModel.height.share(replay: 1)
        
        heightModel
            .asObservable()
            .map { String($0) }
            .bind(to: self.heightLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        blockViewModel.height.onNext(height)
    
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData> (
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BlockDetailTableViewCell
                cell.txHashLabel.text = item.txHash
                cell.fromLabel.text = item.from
                cell.toLabel.text = item.to
                cell.amountLabel.text = "\(item.value?.hexToBigUInt()?.convertToICX() ?? "0")"
                return cell
                
        }, titleForHeaderInSection: { _, _ in
            return "Transactions \(self.txList.count)"
        })
        
        heightModel
            .flatMapLatest { (height) -> Observable<[SectionOfCustomData]> in
                let sections = [SectionOfCustomData(items: self.txList)]
                return Observable.just(sections)
            }
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
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
