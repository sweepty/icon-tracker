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

class ChooseNetworkViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = ChooseNetworkViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Log.Verbose("VIEWWILLDISAPPEAR")
        
    }
    
    func setupUI() {
        viewModel.networks
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] (index, network, cell) in
                self?.setUpBlockCell(cell, network)
                if UserDefaults.standard.integer(forKey: "network") == index {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Int.self)
            .distinctUntilChanged()
            .bind(to: viewModel.selectNetwork)
            .disposed(by: disposeBag)
        
        viewModel.didSelectNetwork
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (network) in
                UserDefaults.standard.set(network, forKey: "network")
                Log.Error("유저 \(UserDefaults.standard.integer(forKey: "network")) 입니다")
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
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
