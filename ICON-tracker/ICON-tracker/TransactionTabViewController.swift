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
    
    var viewModel: TransactionViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TransactionViewModel()
        
        
        
        refreshControl.sendActions(for: .valueChanged)
        
        setupUI()
        setupBindings()
    }
    
    func setupUI() {
        totalSupplyLabel.isHidden = true
        usdPriceLabel.isHidden = true
        
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func setupBindings() {
        segmentedControl.rx.value
            .bind(to: viewModel.segmentedValue)
            .disposed(by: disposeBag)
        
        viewModel.segmentedValue
            .bind(to: segmentedControl.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        
        // Subject(정확히 말하면 BehaviorRelay)는 Observer와 Observable 둘 다 될 수 있기 때문에 하나를 결정해야한다.
        // segmentedValue가 변경되면 로그를 찍어주고 싶기 때문에 Observable로 변경한다.
        // asObservable() = Subject(BehaviorRelay)를 Observable로 변경하는 메서드.
        // Observable<Element>을 리턴한다.
        viewModel.segmentedValue.asObservable()
            .subscribe { (x) in
                Log.Debug("UISegmentedControl value \(String(describing: x))")
            }.disposed(by: disposeBag)
        
        // Current USD Price
        viewModel.currentPrice
            .distinctUntilChanged()
            .bind(to: usdPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentPrice
            .map { $0.isEmpty }
            .bind(to: usdPriceLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Total Supply
        viewModel.icxSupply
            .distinctUntilChanged()
            .bind(to: totalSupplyLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.icxSupply
            .map { $0.isEmpty }
            .bind(to: totalSupplyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // TableView
        viewModel.blockItems
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] (_, block, cell) in
                self?.setUpBlockCell(cell, block)
            }.disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
    }
    
    private func setUpBlockCell(_ cell: UITableViewCell, _ blocks: Block) {
//        cell.textLabel?.text = blocks.hash
        cell.textLabel?.text = "\(blocks.height)"
        cell.detailTextLabel?.text = "\(blocks.txCount)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC: UIViewController? = segue.destination

        if let nvc = destinationVC as? UINavigationController {
            destinationVC = nvc.viewControllers.first
        }

        if let viewController = destinationVC as? ChooseNetworkViewController {
            prepareLanguageListViewController(viewController)
        }
        
    }
    
    /// Setups `LanguageListViewController` befor navigation.
    ///
    /// - Parameter viewController: `LanguageListViewController` to prepare.
    private func prepareLanguageListViewController(_ viewController: ChooseNetworkViewController) {
        let networkListViewModel = ChooseNetworkViewModel()
        
        networkListViewModel.didSelectNetwork
            .bind(to: viewModel.setCurrentNetwork)
            .disposed(by: disposeBag)
        
        viewController.viewModel = networkListViewModel
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
