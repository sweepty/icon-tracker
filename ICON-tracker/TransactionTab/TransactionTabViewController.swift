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
import Charts

class TransactionTabViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var containerView: UIView!
    
    var chartInfoResponse = [ChartInfo]()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize add subviews
        let blockSubView = self.storyboard?.instantiateViewController(withIdentifier: "childA")
        self.addChild(blockSubView!)
        self.containerView.addSubview(blockSubView!.view)
        
        let transactionSubView = self.storyboard?.instantiateViewController(withIdentifier: "childB")
        self.addChild(transactionSubView!)
        self.containerView.addSubview(transactionSubView!.view)
        
        setupBindings()
    }
    
    func setupBindings() {
        // theme        
        view.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
        
        segmentedControl.rx.value
            .bind(to: viewModel.segmentedValue)
            .disposed(by: disposeBag)
        
        viewModel.segmentedValue
            .bind(to: segmentedControl.rx.value)
            .disposed(by: disposeBag)
        
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.segmentedValue.asObservable()
            .subscribe(onNext: { (x) in
                Log.Debug("UISegmentedControl value \(String(describing: x))")
                
                switch x {
                case 0:
                    let childB = self.containerView.subviews.last
                    childB?.isHidden = true
                    
                    let childA = self.containerView.subviews.first
                    childA?.isHidden = false

                default:
                    let childA = self.containerView.subviews.first
                    childA?.isHidden = true
                    
                    let childB = self.containerView.subviews.last
                    childB?.isHidden = false
                    
                }
            })
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

extension UIScrollView {
    var reachedBottom: Observable<Void> {
        return rx.contentOffset
            .flatMap { [weak self] contentOffset -> Observable<Void> in
                guard let scrollView = self else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                return y > threshold ? Observable.just(()) : Observable.empty()
        }
    }
}
