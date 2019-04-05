//
//  ChooseNetworkViewController.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 05/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChooseNetworkViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = ChooseNetworkViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        viewModel.networks
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] (_, network, cell) in
                self?.setUpBlockCell(cell, network)
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Int.self)
            .bind(to: viewModel.selectNetwork)
            .disposed(by: disposeBag)
        
        viewModel.didSelectNetwork
            .distinctUntilChanged()
            .subscribe { (x) in
                Log.Info("\(x)로 바뀜.")
                UserDefaults.standard.set(x.element!, forKey: "network")
//                if let selectedRow = self.tableView.indexPathForSelectedRow {
//                    self.tableView.deselectRow(at: selectedRow, animated: true)
//                    self.tableView.cellForRow(at: selectedRow)?.accessoryType = .checkmark
//                }
            }.disposed(by: disposeBag)
    }
    
    private func updateUserdefaulsNetwork(networkId: Int) {
        UserDefaults.standard.set(networkId, forKey: "network")
    }
    
    private func setUpBlockCell(_ cell: UITableViewCell, _ networks: Int) {
        let labelString: String
        switch networks {
        case 0:
            labelString = "Mainnet"
        case 1:
            labelString = "Testnet for DApps"
        case 2:
            labelString = "Testnet for Exchanges"
        default:
            labelString = "Mainnet"
        }
        cell.textLabel?.text = labelString
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
