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

    @IBOutlet weak var chooseNetworkButton: UIBarButtonItem!
    @IBOutlet weak var usdPriceLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var chartInfoResponse = [ChartInfo]()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.sendActions(for: .valueChanged)
        
        setupUI()
        setupBindings()
        
        setupChartView()
        setupChartData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
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
        
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func setupBindings() {
        // theme        
        view.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
        tableView.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
        
        viewModel.values.asObservable()
            .subscribe(onNext: { (x) in
                // 차트 데이터 변경
                Log.Verbose("차트 데이터 변경함")
                self.lineChartView.data = nil
                self.chartInfoResponse = x
                self.setupChartData()
                // viewwillappear에서도 하는데 reload 때문에 여기서도 해주면 낭비아닐까?
//                self.lineChartView.animate(xAxisDuration: 3.0, yAxisDuration: 3.0)
                
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
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] (_, block, cell) in
                self?.setUpBlockCell(cell, block)
                
                cell.theme.backgroundColor = themeService.attrStream { $0.backgroundColor }
                cell.textLabel?.theme.textColor = themeService.attrStream { $0.textColor }
                cell.detailTextLabel?.theme.textColor = themeService.attrStream { $0.textColor }
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
