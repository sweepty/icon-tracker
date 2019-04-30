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
import Charts

class ChildAViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var usdPriceLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    private let refreshControl = UIRefreshControl()
    
    var chartInfoResponse = [ChartInfo]()
    
    var disposeBag = DisposeBag()
    
    // scroll view test
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hello i'm childA")
        
        refreshControl.sendActions(for: .valueChanged)
        
        setupUI()
        setupBindings()
        setupChartData()
        setupChartView()

//        tableView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("childA will disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("childA did disappear")
    }
    
    func setupChartView() {
        // chartView
//        lineChartView.delegate = self
        lineChartView.pinchZoomEnabled = false
        lineChartView.setScaleEnabled(false)
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.leftAxis.labelTextColor = .white
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
    }
    
    func setupChartData() {
        var values = [ChartDataEntry]()
        
        for i in 0..<chartInfoResponse.count {
            values.append(ChartDataEntry(x: Double(i), y: chartInfoResponse[i].txCount))
        }
        
        let set1 = LineChartDataSet(entries: values, label: nil)
        
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
    
        
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
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
    }
    
    func setupUI() {
        tableView.insertSubview(refreshControl, at: 0)
        totalSupplyLabel.isHidden = true
        usdPriceLabel.isHidden = true
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
