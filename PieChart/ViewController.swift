//
//  ViewController.swift
//  PieChart
//
//  Created by admin on 19/04/2019.
//  Copyright © 2019 VANSA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var dataItems: NSMutableArray = []
    @IBOutlet weak var pieChart: WCPieChart!
    @IBOutlet weak var baseView: WCPieChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseView.layer.cornerRadius = 8.0
        
        // Random Default Value
//        let defaultItemCount = Int.random(in: 1..<4)
//        for _ in 1...defaultItemCount {
//            dataItems.add(randomItem())
//        }
        
        let exampleData1 = PieChartItem(value: 10800000, color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), description: "매촐(17건)")
        let exampleData2 = PieChartItem(value: 2125000, color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), description: "매입(7건)")
        let exampleData3 = PieChartItem(value: 1125000, color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), description: "매입(7건)")
        let exampleData4 = PieChartItem(value: 2125000, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), description: "매입(7건)")
        let exampleData5 = PieChartItem(value: 2125000, color: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), description: "매입(7건)")
        let exampleData6 = PieChartItem(value: 2125000, color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), description: "매입(7건)")
        dataItems.add(exampleData1)
        dataItems.add(exampleData2)
        dataItems.add(exampleData3)
//        dataItems.add(exampleData4)
//        dataItems.add(exampleData5)
//        dataItems.add(exampleData6)
        
        pieChart.delegate = self
        pieChart.dataSource = self
    }
    
    @IBAction func reloadAction(_ sender: UIBarButtonItem) {
        dataItems.removeAllObjects()
        let defaultItemCount = Int.random(in: 1..<4)
        for _ in 1...defaultItemCount {
            dataItems.add(randomItem())
        }
        pieChart.reloadData()
    }
    
    func randomItem() -> PieChartItem {
        let value = CGFloat(Int.random(in: 1..<4))
        let color = randomColor()
        let description = "\(value)"
        return PieChartItem(value: Double(value), color: color, description: description)
    }
    
    func randomColor() -> UIColor {
        let randomR: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let randomG: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let randomB: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return UIColor(red: randomR, green: randomG, blue: randomB, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pieChart.reloadData()
    }

    private func goGo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.performSegue(withIdentifier: "go_go", sender: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension ViewController: WCPieChartDelegate {
    func pieChart(pieChart: WCPieChart, height: CGFloat) {
        
    }
    
    func pieChart(pieChart: WCPieChart, itemSelectedAtIndex index: Int) {
        
    }
    
    func pieChart(pieChart: WCPieChart, itemDeselectedAtIndex index: Int) {
        
    }
}

extension ViewController: WCPieChartDataSource {
    func frameOfCell(pieChart: WCPieChart) -> CGRect {
        return CGRect.zero
    }
    
    func numberOfSlicesInPieChart(pieChart: WCPieChart) -> Int {
        return dataItems.count
    }
    
    func pieChart(pieChart: WCPieChart, valueForSliceAtIndex index: Int) -> Double {
        let item: PieChartItem = dataItems[index] as! PieChartItem
        return item.value
    }
    
    func pieChart(pieChart: WCPieChart, colorForSliceAtIndex index: Int) -> UIColor {
        let item: PieChartItem = dataItems[index] as! PieChartItem
        return item.color
    }
    
    func pieChart(pieChart: WCPieChart, titleForSliceAtIndex index: Int) -> String {
        let item: PieChartItem = dataItems[index] as! PieChartItem
        return item.description ?? ""
    }
}

