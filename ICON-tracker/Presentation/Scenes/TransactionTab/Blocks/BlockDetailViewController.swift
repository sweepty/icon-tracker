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
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var txfeeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let blockViewModel = BlockDetailViewModel()
    
    var disposeBag = DisposeBag()
    
    var height = UInt64()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rowHeight = 120
        
        self.hashLabel.textColor = ColorChip.topaz!
        self.peerIdLabel.textColor = ColorChip.labelColor!
        
        self.amountLabel.textColor = ColorChip.labelColor!
        self.timestampLabel.textColor = ColorChip.labelColor!
        self.txfeeLabel.textColor = ColorChip.labelColor!
        
        setupBind()
    }
    
    func setupBind() {
        let heightModel = blockViewModel.height.share(replay: 1)
        
        heightModel
            .subscribe(onNext: { (x) in
                print("높이 \(x)")
                self.height = x
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
                self.hashLabel.text = blockInfo.hash
                self.peerIdLabel.text = blockInfo.peerId
                
                self.amountLabel.text = blockInfo.amount
                self.timestampLabel.text = blockInfo.createDate
                self.txfeeLabel.text = blockInfo.fee
                
                print("blockInfo: \(blockInfo)")
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Response.Block.ConfirmedTransactionList.self)
            .subscribe(onNext: { (cell) in
                let txVC = UIStoryboard(name: "TransactionDetail", bundle: nil).instantiateInitialViewController() as! TransactionDetailViewController
                txVC.hashString = cell.txHash
                self.navigationController?.pushViewController(txVC.self, animated: true)
            })
            .disposed(by: disposeBag)
        
        blockInfo
            .map{ String($0.height) }
            .bind(to: self.heightLabel.rx.text)
            .disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData> (
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BlockDetailTableViewCell
                cell.txHashLabel.text = item.txHash
                cell.fromLabel.text = item.from
                cell.toLabel.text = item.to
                cell.amountLabel.text = "\(item.value?.hexToBigUInt()?.convertToICX() ?? "0")"
                
                cell.fromTitleView.layer.cornerRadius = 5
                cell.toTtitleView.layer.cornerRadius = 5
                cell.icxView.layer.cornerRadius = 5
                
                return cell

        }, titleForHeaderInSection: { datasource, index in
            return "Transactions \(datasource[index].items.count)"
        })
        
        blockViewModel.txList
            .map { [SectionOfCustomData(items: $0)] }
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        blockViewModel.height.onNext(height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

}
