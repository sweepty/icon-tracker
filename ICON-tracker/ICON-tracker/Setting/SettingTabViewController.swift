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
import RxTheme

class SettingTabViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    private let sviewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Bind stream to a single attribute
        // In the way, RxTheme would automatically manage the lifecycle of the binded stream
        view.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
        tableView.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
    }
    
    func setupUI() {
        sviewModel.settingList.asDriver(onErrorJustReturn: ["error"])
            .drive(tableView.rx.items(cellIdentifier: "cell2", cellType: SettingTabTableViewCell.self)) { (_, title, cell) in
                cell.textLabel?.text = title
                
                if title != "Dark mode" {
                    cell.switchButton.isHidden = true
                } else {
                    cell.switchButton.isOn = UserDefaults.standard.bool(forKey: "darkmode")
                }
                
                let switched = cell.switchButton.rx.isOn.changed
                    .distinctUntilChanged()
                    .observeOn(MainScheduler.instance)
                    .share()
                
                switched
                    .subscribe({ (x) in
                        UserDefaults.standard.set(x.element!, forKey: "darkmode")
                        Log.Debug("스위치가 \(x.element!)로 바뀌었습니다.")
                    })
                    .disposed(by: cell.cellBag)
                
                switched
                    .subscribe({ (x) in
                        if x.element! {
                            themeService.switch(.dark)
                        } else {
                            themeService.switch(.light)
                        }
                    }).disposed(by: cell.cellBag)
                
                cell.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
                
        }.disposed(by: disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC: UIViewController? = segue.destination
        
        if let nvc = destinationVC as? UINavigationController {
            destinationVC = nvc.viewControllers.first
        }
        
        if let viewController = destinationVC as? ChooseNetworkViewController, segue.identifier == "showNetworkList" {
            prepareNetworkListViewController(viewController)
        }
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
