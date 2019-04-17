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
    
    @IBOutlet weak var chooseNetworkButton: UIBarButtonItem!
    @IBOutlet weak var usdPriceLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var containerView: UIView!
    
    var chartInfoResponse = [ChartInfo]()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.sendActions(for: .valueChanged)
        
        // initial add subviews
        let blockSubView = self.storyboard?.instantiateViewController(withIdentifier: "childA")
        self.addChild(blockSubView!)
        self.containerView.addSubview(blockSubView!.view)
        
        let transactionSubView = self.storyboard?.instantiateViewController(withIdentifier: "childB")
        self.addChild(transactionSubView!)
        self.containerView.addSubview(transactionSubView!.view)
        
        
        setupUI()
        setupBindings()
        
        setupChartView()
        setupChartData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
    
    func setupChartView() {
        // chartView
        lineChartView.delegate = self
        lineChartView.pinchZoomEnabled = false
        lineChartView.setScaleEnabled(false)
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.leftAxis.labelTextColor = .white
        lineChartView.rightAxis.enabled = false
        
    }
    
    func setupChartData() {
        var values = [ChartDataEntry]()
        
        for i in 0..<chartInfoResponse.count {
            values.append(ChartDataEntry(x: Double(i), y: chartInfoResponse[i].txCount))
        }
        
        let set1 = LineChartDataSet(values: values, label: "Set 1")
        
        set1.drawIconsEnabled = false
        set1.setColor(.white)
        set1.setCircleColor(.white)
        set1.lineWidth = 1
        set1.circleRadius = 3
        set1.valueFont = .systemFont(ofSize: 9)
        set1.valueTextColor = .white
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let data = LineChartData(dataSet: set1)
        
        lineChartView.data = data
    }
    
    func setupUI() {
        totalSupplyLabel.isHidden = true
        usdPriceLabel.isHidden = true
        
    }
    
    func setupBindings() {
        // theme        
        view.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
        
        viewModel.values.asObservable()
            .subscribe(onNext: { (x) in
                // 차트 데이터 변경
                Log.Verbose("차트 데이터 변경함")
                self.lineChartView.data = nil
                self.chartInfoResponse = x
                self.setupChartData()
                
            }).disposed(by: disposeBag)
        
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
        
        // scroll test
//        viewModel.nextPageTrigger.asObservable()
//            .subscribe(onNext: { (_) in
//                Log.Info("다음페이지로 가고 맨 위로 올리자")
//                self.view.bringSubviewToFront(self.containerView)
////                view.topAnchor.constraint(equalTo: gamePreview.topAnchor, constant: 0)
//                self.containerView.addConstraint(self.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0))
//                
//            })
//            .disposed(by: disposeBag)
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
