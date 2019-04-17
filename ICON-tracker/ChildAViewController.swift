//
//  ChildAViewController.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 17/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChildAViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    var disposeBag = DisposeBag()
    
    // scroll view test
    var oldContentOffset = CGPoint.zero
    let topConstraintRange = (CGFloat(0)..<CGFloat(140))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hello i'm childA")
        
        refreshControl.sendActions(for: .valueChanged)
        
        setupUI()
        setupBinding()

//        tableView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("childA will disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("childA did disappear")
    }
    
    func setupUI() {
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func setupBinding() {
        viewModel.blockItems
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
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        tableView.reachedBottom
            .map { _ in () }
            .bind(to: viewModel.nextPageTrigger)
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
