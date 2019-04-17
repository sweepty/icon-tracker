//
//  ChildBViewController.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 17/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChildBViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("helllo i'm childB")
        
        refreshControl.sendActions(for: .valueChanged)
        
        setupUI()
        setupBinding()

        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func setupBinding() {
        viewModel.transactionItems
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (_, block, cell) in

                cell.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
                cell.textLabel?.theme.textColor = themeService.attrStream { $0.textColor }
                cell.detailTextLabel?.theme.textColor = themeService.attrStream { $0.textColor }
                
                cell.textLabel?.text = "\(block.height)"
                cell.detailTextLabel?.text = block.createDate
            }
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.tReload)
            .disposed(by: disposeBag)
        
        tableView.reachedBottom
            .map { _ in () }
            .bind(to: viewModel.tNextPageTrigger)
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
