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

class ChildAViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    var chartInfoResponse = [ChartInfo]()
    
    var disposeBag = DisposeBag()
    
    // scroll view test
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hello i'm childA")
        
        refreshControl.sendActions(for: .valueChanged)
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        setupUI()
        setupBindings()
        setupChartData()
        setupChartView()
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
//        lineChartView.pinchZoomEnabled = false
//        lineChartView.setScaleEnabled(false)
//        lineChartView.xAxis.labelPosition = .bottom
//        lineChartView.xAxis.labelTextColor = .white
//        lineChartView.xAxis.valueFormatter = self
//        lineChartView.leftAxis.labelTextColor = .white
//        lineChartView.rightAxis.enabled = false
//        lineChartView.legend.enabled = false
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
        
//        lineChartView.data = data
    }
    
    func setupBindings() {
        viewModel.values.asObservable()
            .subscribe(onNext: { (x) in
                // 차트 데이터 변경
                Log.Verbose("차트 데이터 변경함")
//                self.lineChartView.data = nil
                self.chartInfoResponse = x
                self.setupChartData()
                
            }).disposed(by: disposeBag)
    
        
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.blockItems
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: ChildATableViewCell.self)) { (_, block, cell) in
                
                cell.heightLabel?.text = "\(block.height)"
                cell.hashLabel?.text = block.hash
                cell.txCountLabel?.text = "\(block.txCount)"
                cell.timestampLabel?.text = block.createDate.calculateAge() + "\t ago"
                
            }
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        tableView.reachedBottom
            .map { _ in () }
            .bind(to: viewModel.nextPageTrigger)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Block.self)
            .subscribe(onNext: { (block) in
                let detailVC = UIStoryboard(name: "BlockDetail", bundle: nil).instantiateInitialViewController() as! BlockDetailViewController
                detailVC.height = UInt64(block.height)
                self.navigationController?.pushViewController(detailVC.self, animated: true)
            })
            .disposed(by: disposeBag)
        
        // Current USD Price
        let currentPriceObservable = viewModel.currentPrice
            .distinctUntilChanged()
        
//        currentPriceObservable
//            .drive(usdPriceLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        currentPriceObservable
//            .map { $0.isEmpty }
//            .drive(usdPriceLabel.rx.isHidden)
//            .disposed(by: disposeBag)
        
        // Total Supply
//        let icxSupplyObservable = viewModel.icxSupply
//            .distinctUntilChanged()
//
//        icxSupplyObservable
//            .drive(totalSupplyLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        icxSupplyObservable
//            .map { $0.isEmpty }
//            .drive(totalSupplyLabel.rx.isHidden)
//            .disposed(by: disposeBag)
    }
    
    func setupUI() {
        tableView.insertSubview(refreshControl, at: 0)
//        totalSupplyLabel.isHidden = true
//        usdPriceLabel.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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

extension ChildAViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let target: String = chartInfoResponse[Int(value)].targetDate
        let date = mmdd(dateString: target)
        return date
    }
    
    func mmdd(dateString: String) -> String {
        let date = dateString.toDate()
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM d"
        let result = dateformatter.string(from: date)
        return result
    }
}
