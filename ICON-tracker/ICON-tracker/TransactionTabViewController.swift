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

class TransactionTabViewController: UIViewController {

    @IBOutlet weak var usdPriceLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var pageNumber: Int = 1
    var blockItems = [Block]()
    var transactionItems = [TransactionBlock]()
    
    let requests = Requests()
    
    let trackerService = TrackerService()
    
    // Rx
    private let disposeBag = DisposeBag()
    
    @IBAction func selectNetworkBarButton(_ sender: UIBarButtonItem) {
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        totalSupplyLabel.isHidden = true
        usdPriceLabel.isHidden = true
        
        // BehaviorRelay는 BehaviorSubject의 wrapper로써 RxSwift 4.0에서 deprecated된 Variable와 개념이 동일하다.
        // 즉, onNext만 사용가능하고, 할당이 해제되면 자동으로 onCompleted() 이벤트를 보낸다. (maybe)
        // error나 completed로 종료되지 않는다.
        // BehaviorSubject는 Subject에 의해 반환된 가장 최근 값과 구독 이후 반환한 값을 가져오기 때문에
        // 앱을 빌드하면 SegementedControl의 값을 변환하지 않았어도 기본값인 0이 있기 때문에 아래처럼 바로 로그가 찍히는 것이다.
        // UISegmentedControl value next(0)
        let segmentedValue = BehaviorRelay(value: 0)
        
        // 양방향으로 바인딩.
        _ = segmentedControl.rx.value <-> segmentedValue
        
        // Subject(정확히 말하면 BehaviorRelay)는 Observer와 Observable 둘 다 될 수 있기 때문에 하나를 결정해야한다.
        // segmentedValue가 변경되면 로그를 찍어주고 싶기 때문에 Observable로 변경한다.
        // asObservable() = Subject(BehaviorRelay)를 Observable로 변경하는 메서드.
        // Observable<Element>을 리턴한다.
        segmentedValue.asObservable()
            .subscribe { (x) in
                Log.Debug("UISegmentedControl value \(String(describing: x))")
        }.disposed(by: disposeBag)
        
        // price
        setPrice()
        
        // total supply
        setTotalSupply()

        setBlockList()
        
        setTransactionList()
    }
    
    // Block 리스트 받아오기
    // 근데 infinity scroll로 만드려면?🤔
    func setBlockList() {
        // Observable
        let blockObservable = trackerService.getBlockList(page: 1)
        
        blockObservable.subscribe(onNext: { (blocks) in
            self.blockItems = blocks
            Log.Info("받아오기 성공")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
    }
    
    // transaction list 받아오기
    func setTransactionList() {
        let ob = trackerService.getTransactionList(page: 1)
        ob.subscribe(onNext: { (transactions) in
            self.transactionItems = transactions
            Log.Info("트랜젝션 받아오기 성공")
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        }).disposed(by: disposeBag)
    }
    
    func setPrice() {
        let response = trackerService.getCurrentExchange()
        
        response
            .bind(to: usdPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        let labelisHidden = response.map { $0.isEmpty }
        labelisHidden
            .bind(to: usdPriceLabel.rx.isHidden )
            .disposed(by: disposeBag)
    }
    
    func setTotalSupply() {
        requests.getTotalSupply { (result) in
            guard let result = result else {
                DispatchQueue.main.async {
                    self.totalSupplyLabel.text = "00000"
                }
                return
            }
            let ans = result.convertToICX()
            DispatchQueue.main.async {
                self.totalSupplyLabel.isHidden = false
                self.totalSupplyLabel.text = "\(ans)"
                self.totalSupplyLabel.sizeToFit()
            }
        }
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

//// pure swift ver
extension TransactionTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.blockItems[indexPath.row].hash
        cell.detailTextLabel?.text = self.blockItems[indexPath.row].createDate
        return cell
    }
}
