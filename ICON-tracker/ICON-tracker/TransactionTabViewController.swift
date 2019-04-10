//
//  TransactionTabViewController.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 01/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BigInt

class TransactionTabViewController: UIViewController {

    @IBOutlet weak var chooseNetworkButton: UIBarButtonItem!
    @IBOutlet weak var usdPriceLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.sendActions(for: .valueChanged)
        
        setupUI()
        setupBindings()
    }
    
    func setupUI() {
        
        totalSupplyLabel.isHidden = true
        usdPriceLabel.isHidden = true
        
        tableView.insertSubview(refreshControl, at: 0)
        
//        tableView.rx.prefetchDataSource.self
//        
//        tableView.rx.prefetchRows
//            .subscribe(onNext: { (indexPath) in
//                if indexPath.first!.row % 24 == 0 {
//                    Log.Info("24의 배수ㅎㅅㅎ")
//                    let page: Int = indexPath.first!.row / 24
//                    let pageOb: Observable<Int> = Observable.just(page)
//                    pageOb
//                        .bind(to: viewModel.pageNums)
//                        .disposed(by: self.disposeBag)
//                    
//                    viewModel.blockItems.asObservable()
//                        
//                }
//            })
//            .disposed(by: disposeBag)
        
    }
    
    func setupBindings() {
        // theme        
        view.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
        tableView.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
        
        segmentedControl.rx.value
            .bind(to: viewModel.segmentedValue)
            .disposed(by: disposeBag)
        
        viewModel.segmentedValue
            .bind(to: segmentedControl.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.segmentedValue.asObservable()
            .subscribe { (x) in
                Log.Debug("UISegmentedControl value \(String(describing: x))")
            }.disposed(by: disposeBag)
        
        // Current USD Price
        let currentPriceObservable = viewModel.currentPrice
            .distinctUntilChanged()
        
        currentPriceObservable
            .drive(usdPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        currentPriceObservable
            .map { $0.isEmpty }
            .drive(usdPriceLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Total Supply
        let icxSupplyObservable = viewModel.icxSupply
            .distinctUntilChanged()
        
        icxSupplyObservable
            .drive(totalSupplyLabel.rx.text)
            .disposed(by: disposeBag)
        
        icxSupplyObservable
            .map { $0.isEmpty }
            .drive(totalSupplyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // TableView
        viewModel.blockItems
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] (_, block, cell) in
                self?.setUpBlockCell(cell, block)
                
                cell.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
                cell.textLabel?.theme.textColor = themeService.attrStream { $0.textColor }
                cell.detailTextLabel?.theme.textColor = themeService.attrStream { $0.textColor }
            }
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
    }
    
    private func setUpBlockCell(_ cell: UITableViewCell, _ blocks: Block) {
//        cell.textLabel?.text = blocks.hash
        cell.textLabel?.text = "\(blocks.height)"
        cell.detailTextLabel?.text = "\(blocks.txCount)"
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

extension UIScrollView {
    func isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}
