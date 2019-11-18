//
//  SettingTabViewController.swift
//  ICON-tracker
//
//  Created by Seungyeon Lee on 09/04/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AcknowList

class SettingTabViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    private let sviewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        sviewModel.settingList.asDriver(onErrorJustReturn: ["error"])
            .drive(tableView.rx.items(cellIdentifier: "cell2", cellType: SettingTabTableViewCell.self)) { (index, title, cell) in
                cell.textLabel?.text = title
                
                switch index {
                case 1:
                    cell.selectionStyle = .none
                    cell.switchButton.isOn = UserDefaults.standard.bool(forKey: "darkmode")
                default:
                    cell.switchButton.isHidden = true
                }
                
                let switched = cell.switchButton.rx.isOn.changed
                    .distinctUntilChanged()
                    .observeOn(MainScheduler.instance)
                    .share()
                
                switched
                    .subscribe(onNext: { (value) in
                        UserDefaults.standard.set(value, forKey: "darkmode")
                        Log.Debug("스위치가 \(value)로 바뀌었습니다.")
                    })
                    .disposed(by: cell.cellBag)
                
                
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                
                switch indexPath.row {
                case 0:
                    let networkVC = UIStoryboard(name: "ChooseNetwork", bundle: nil).instantiateViewController(withIdentifier: "ChooseNetwork") as! ChooseNetworkViewController
                    self?.navigationController?.pushViewController(networkVC.self, animated: true)
                    self?.prepareNetworkListViewController(networkVC)
                case 2:
                    let viewController = AcknowListViewController()
                    self?.navigationController?.pushViewController(viewController.self, animated: true)
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
        
    }

    private func prepareNetworkListViewController(_ viewController: ChooseNetworkViewController) {
        
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
