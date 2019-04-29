//
//  ListPieViewController.swift
//  PieChart
//
//  Created by admin on 25/04/2019.
//  Copyright © 2019 VANSA. All rights reserved.
//

import UIKit
//import AudioToolbox

class ListPieViewController: UIViewController {

    @IBOutlet weak var pieTableVeiw: UITableView!
    @IBOutlet var toastViw: UIView!
    @IBOutlet weak var detailInfoLb: UILabel!
    @IBOutlet weak var viwSignColor: UIView!
    
    //setup information detail pie
    let topAndBottomSpacePie: CGFloat = 16.0
    let titleHeightPie: CGFloat = 15.0
    let spaceTitleAndValuePie: CGFloat = 8.0
    let valueHieghtPie: CGFloat = 15.0
    
    var dataSource = [[PieChartItem]]()
    var heightMyCell = Array<CGFloat>()
    
    private func calculateHeightCell(dataSource: [PieChartItem]) -> CGFloat {
        if dataSource.count == 0 { return 0 }
        var tempHeight: CGFloat = 0.0
        var numberOfSlince = dataSource.count
        if dataSource.count == 1 { numberOfSlince += 1 }
        
        let spaceTop: CGFloat = topAndBottomSpacePie
        tempHeight += spaceTop
        
        if numberOfSlince == 0 { tempHeight = 0.0 }
        for _ in 0..<numberOfSlince { tempHeight += (titleHeightPie + spaceTitleAndValuePie + valueHieghtPie + topAndBottomSpacePie)}
        return tempHeight + 16
    }
    
    
    
    private func setupToastBar() {
        let h: CGFloat = 100
        let x: CGFloat = 16
        let y: CGFloat = -126
        let w :CGFloat = self.view.frame.width - (x*2)
        let f = CGRect(x: x, y: y, width: w, height: h)
        toastViw.frame = f
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: toastViw.bounds, cornerRadius: 16).cgPath
        shadowLayer.fillColor = UIColor.clear.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowRadius = 2
        shadowLayer.shadowOpacity = 0.1
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: -1, height: 1)
        toastViw.layer.insertSublayer(shadowLayer, at: 0)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = toastViw.bounds
        blurEffectView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = 16
        blurEffectView.clipsToBounds = true
        toastViw.insertSubview(blurEffectView, at: 1)
        
        toastViw.backgroundColor = UIColor.clear
        self.view.addSubview(toastViw)
    }
    
    public func showToastBar(isShow: Bool) {
        let x = toastViw.frame.origin.x
        let w = toastViw.frame.width
        let h = toastViw.frame.height
        let y = toastViw.frame.origin.y
        if isShow {
            if y == -126 {
                let nFrame = CGRect(x: x, y: 26, width: w, height: h)
                UIView.animate(withDuration: 0.3, animations: {
                    self.toastViw.frame = nFrame
                    self.view.layoutIfNeeded()
                }) { (status) in
                    self.shake(viw: self.toastViw)
                }
            }
        } else {
            if y == 26 {
                let nFrame = CGRect(x: x, y: -126, width: w, height: h)
                UIView.animate(withDuration: 0.3) {
                    self.toastViw.frame = nFrame
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func shake(viw: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: viw.center.x - 4, y: viw.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: viw.center.x + 4, y: viw.center.y))
        viw.layer.add(animation, forKey: "position")
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let exampleData1 = [
            PieChartItem(value: 10800000, color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), description: "매출(17건)"),
            PieChartItem(value: 2125000, color: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), description: "매입(7건)"),
            PieChartItem(value: 2125000, color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), description: "안녕하세요.")
        ]
        let exampleData2 = [
            PieChartItem(value: 12300000, color: #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1), description: "입금(6건)"),
            PieChartItem(value: 8835000, color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), description: "출금(5건)")
        ]
        let exampleData3 = [
            PieChartItem(value: 1525, color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), description: "고마워요."),
        ]
        let exampleData4 = [
            PieChartItem(value: 2655, color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), description: "Ronaldo유니"),
            PieChartItem(value: 1235, color: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), description: "완사"),
            PieChartItem(value: 4565, color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), description: "Neymar"),
            PieChartItem(value: 4565, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), description: "Zidane"),
            PieChartItem(value: 10800, color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), description: "매출(17건)"),
            PieChartItem(value: 2100, color: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), description: "매입(7건)"),
            PieChartItem(value: 21250, color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), description: "안녕하세요.")
        ]
        dataSource.append(exampleData3)
        dataSource.append(exampleData1)
        dataSource.append(exampleData2)
        dataSource.append(exampleData4)
        
        setupToastBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pieTableVeiw.reloadData()
    }
    
    @IBAction func reloadAction(_ sender: UIButton) {
        pieTableVeiw.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public func itemSelector(item: PieChartItem) {
        viwSignColor.layer.cornerRadius = 16
        viwSignColor.backgroundColor = item.color
        detailInfoLb.text = "\(item.description!)\r\(item.value)"
        showToastBar(isShow: true)
    }
    
}

extension ListPieViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pieCell = tableView.dequeueReusableCell(withIdentifier: "PieCustomCell", for: indexPath) as? PieCustomCell else { return UITableViewCell() }
        pieCell.renderCell(vc: self, data: dataSource[indexPath.row], cellFrame: pieCell.frame)
        pieCell.delegate = self
        return pieCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dataRec = dataSource[indexPath.row]
        return calculateHeightCell(dataSource: dataRec)
    }
}

class PieCustomCell: UITableViewCell {
    @IBOutlet weak var wcPieChart: WCPieChart!
    var pieDataSource = Array<PieChartItem>()
    var cellFrame: CGRect = CGRect.zero
    var itemSelector: Selector?
    weak var delegate: ListPieViewController?
    
    public func renderCell(vc: UIViewController, data: Array<PieChartItem>, cellFrame: CGRect) {
        pieDataSource = data
        setupInformationPie(vc: vc)
        self.cellFrame = cellFrame
        wcPieChart.dataSource = self
    }
    
    private func setupInformationPie(vc: UIViewController) {
        guard let listPieVc = vc as? ListPieViewController else { return }
        wcPieChart.spaceValueAndTitle = listPieVc.topAndBottomSpacePie
        wcPieChart.titleHeight = listPieVc.titleHeightPie
        wcPieChart.spaceTitleAndValue = listPieVc.spaceTitleAndValuePie
        wcPieChart.valueHeight = listPieVc.titleHeightPie
    }
}

extension PieCustomCell: WCPieChartDelegate {
    func pieChart(pieChart: WCPieChart, itemSelectedAtIndex index: Int) {
        let item = pieDataSource[index]
        delegate?.itemSelector(item: item)
    }
    func pieChart(pieChart: WCPieChart, itemDeselectedAtIndex index: Int) {
        delegate?.showToastBar(isShow: false)
    }
}

extension PieCustomCell: WCPieChartDataSource {
    
    func frameOfCell(pieChart: WCPieChart) -> CGRect {
        return cellFrame
    }
    
    func numberOfSlicesInPieChart(pieChart: WCPieChart) -> Int {
        return pieDataSource.count
    }
    
    func pieChart(pieChart: WCPieChart, valueForSliceAtIndex index: Int) -> Double {
        return pieDataSource[index].value
    }
    
    func pieChart(pieChart: WCPieChart, colorForSliceAtIndex index: Int) -> UIColor {
        return pieDataSource[index].color
    }
    
    func pieChart(pieChart: WCPieChart, titleForSliceAtIndex index: Int) -> String {
        return pieDataSource[index].description ?? ""
    }
    
    
}
