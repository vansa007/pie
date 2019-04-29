//
//  PieChartView.swift
//  PieChart
//
//  Created by admin on 19/04/2019.
//  Copyright © 2019 VANSA. All rights reserved.
//

import UIKit

class PieChartView: UIView {
    
    /*
     * injection
     */
    var isExample: Bool = true
    var lineHeight: CGFloat = 1.0
    var padding: CGFloat = 5.0
    var spacePie: CGFloat = 0
    
    var dataSourceChartPie = Array<PieModel>()

    /*
     * drawing by system
     */
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.clear
        padding = lineHeight + padding
        transform = CGAffineTransform(rotationAngle: CGFloat.pi * (3/2))
        
        let totalValue = getTotalValue(pieArr: dataSourceChartPie)
        drawPieAction(pieModel: dataSourceChartPie, totalValue: totalValue)
    }
    
    private func getTotalValue(pieArr: [PieModel]) -> Double {
        var valueArr: Double = 0
        for pie in pieArr {valueArr += pie.value }
        return valueArr
    }
    
    private func getAngleFromEachValue(totalValue: Double, itemValue: Double) -> CGFloat {
        return CGFloat(((itemValue/totalValue) * 360))
    }
    
    private func angleToRadius(angle: CGFloat) -> CGFloat {
        return (angle * CGFloat.pi) / 180
    }
    
    private func drawPieAction(pieModel: [PieModel], totalValue: Double) {
        var lastStatAngle: CGFloat = 0
        var lastEndAngle: CGFloat = 0
        for (index, pieData) in pieModel.enumerated() {
            
            var space = spacePie
            if dataSourceChartPie.count < 2 { space = 0.0 }
            if index != 0 {
                space = 0.0
            }
            
            guard let context = UIGraphicsGetCurrentContext() else { return }
            let radius = min(frame.width - padding, frame.height - padding) * 0.5
            let center = CGPoint(x: frame.width/2, y: frame.height/2)
            context.setLineWidth(lineHeight)
            context.setStrokeColor(pieData.color.cgColor)
            

            let idx = index == 0 ? 0 : 1
            var v = pieModel[index - idx].value
            if index == 0 {
                v = 0
            }
            let rawStartAngleValue = getAngleFromEachValue(totalValue: totalValue, itemValue: v)
            let rawEndAngleValue = getAngleFromEachValue(totalValue: totalValue, itemValue: pieData.value)
            
            let startAngle: CGFloat = angleToRadius(angle: rawStartAngleValue) + lastStatAngle
            let endAngle: CGFloat = angleToRadius(angle: rawEndAngleValue) + lastEndAngle
            
            lastStatAngle = startAngle
            lastEndAngle = endAngle
            
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.strokePath()
        }
    }
    
    @objc func handler(gesture: UITapGestureRecognizer) {
        
    }
}

class PieModel {
    
    let color: UIColor
    let titleValue: String
    let value: Double
    
    init(color: UIColor, titleValue: String, value: Double) {
        self.color = color
        self.titleValue = titleValue
        self.value = value
    }
    
}


@IBDesignable
class PieChartViewTexture: UIView {
    
    var heightView: CGFloat = 0
    
    lazy var pieView: PieChartView = {
        let pView = PieChartView()
        pView.backgroundColor = UIColor.clear
        pView.isExample = false
        pView.lineHeight = 22.0
        pView.padding = 5.0
        pView.spacePie = 5.0
        return pView
    }()
    
    lazy var wcPieChart: WCPieChart = {
        let pieChart = WCPieChart()
        return pieChart
    }()
    
    override func draw(_ rect: CGRect) {
        setDefaultHeightView()
        setupExampleData()
        setupDetailList()
    }
    
    private func setDefaultHeightView() {
        let xMainView = self.frame.origin.x
        let yMainView = self.frame.origin.y
        let widthMainView = self.frame.width
        let fitHeight = (widthMainView / 3.2) + 8 + 8
        heightView = fitHeight
        self.frame = CGRect(x: xMainView, y: yMainView, width: widthMainView, height: fitHeight)
    }
    
    private func setupExampleData() {
        let testPieModel1 = PieModel(color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), titleValue: "매출(17건)", value: 6)
        let testPieModel2 = PieModel(color: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), titleValue: "입금(6건)", value: 1)
        let testPieModel3 = PieModel(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), titleValue: "입금(8건)", value: 12)
        let testPieModel4 = PieModel(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), titleValue: "입금(8건)", value: 13)
        let pieModelArr = [testPieModel2, testPieModel3]
        pieView.dataSourceChartPie = pieModelArr
    }
    
    private func setupDetailList() {
        let widthMainView = self.frame.width
        var tempHeight: CGFloat = 0.0
        
        let spaceTop: CGFloat = 16.0
        tempHeight += spaceTop
        
        for picData in pieView.dataSourceChartPie {
            let titleSt = "• \(picData.titleValue)"
            let dotRange = (titleSt as NSString).range(of: "•")
            let attributedString = NSMutableAttributedString(string: titleSt)
            let colorAttr = [
                NSAttributedString.Key.foregroundColor : picData.color,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 25)
            ]
            attributedString.addAttributes(colorAttr, range: dotRange)
            let titleLb = UILabel()
            titleLb.font = UIFont.systemFont(ofSize: 16)
            titleLb.attributedText = attributedString
            let titleHeight: CGFloat = 16.0
            let titleX = widthMainView / 2.2
            let widthTitle = self.frame.width - titleX
            let titleFr = CGRect(x: titleX, y: tempHeight, width: widthTitle, height: titleHeight)
            titleLb.frame = titleFr
            self.addSubview(titleLb)
            tempHeight += titleHeight
            
            let spaceTitleAndValue: CGFloat = 8.0
            tempHeight += spaceTitleAndValue
            
            //setup value amount
            let amountLb = UILabel()
            amountLb.font = UIFont.boldSystemFont(ofSize: 16)
            amountLb.text = formatWonCurrency(amt: picData.value, currencyType: "원")
            let valueHeight: CGFloat = 16.0
            let widthValue = self.frame.width - titleX
            let amountFr = CGRect(x: titleX, y: tempHeight, width: widthValue, height: valueHeight)
            amountLb.frame = amountFr
            self.addSubview(amountLb)
            tempHeight += valueHeight
            
            let spaceValueAndTitle: CGFloat = 16.0
            tempHeight += spaceValueAndTitle
        }
        
        if tempHeight > heightView {
            heightView = tempHeight
            let xMainView = self.frame.origin.x
            let yMainView = self.frame.origin.y
            let widthMainView = self.frame.width
            let fitHeight = tempHeight
            self.frame = CGRect(x: xMainView, y: yMainView, width: widthMainView, height: fitHeight)
        }
        setupPieView()
    }
    
    private func setupPieView() {
        let widthMainView = self.frame.width
        let heightMainView = self.frame.height
        
        let widthPie = widthMainView / 3.2
        let heightPie = widthPie
        let centerVer = heightMainView/2 - heightPie/2
        let centerHor = (widthMainView/3.2 - widthPie/2)/2
        let center = CGPoint(x: centerHor, y: centerVer)
        let pieFr = CGRect(x: center.x, y: center.y, width: widthPie, height: heightPie)
        pieView.frame = pieFr
        self.addSubview(pieView)
    }
    
    func formatWonCurrency(amt: Double, currencyType: String = "") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "en_US")
        let format = formatter.string(from: NSNumber(floatLiteral: amt))! + " " + currencyType
        return format
    }
    
}
