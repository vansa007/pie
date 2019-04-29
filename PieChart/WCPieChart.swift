//
//  MyPie.swift
//  PieChart
//
//  Created by admin on 23/04/2019.
//  Copyright © 2019 VANSA. All rights reserved.
//

import UIKit

//WCPieChart delegate
public protocol WCPieChartDelegate: class {
    func pieChart(pieChart: WCPieChart, itemSelectedAtIndex index: Int)
    func pieChart(pieChart: WCPieChart, itemDeselectedAtIndex index: Int)
}

//WCPieChart datasource
public protocol WCPieChartDataSource: class {
    func numberOfSlicesInPieChart(pieChart: WCPieChart) -> Int
    func pieChart(pieChart: WCPieChart, valueForSliceAtIndex index: Int) -> Double
    func pieChart(pieChart: WCPieChart, colorForSliceAtIndex index: Int) -> UIColor
    func pieChart(pieChart: WCPieChart, titleForSliceAtIndex index: Int) -> String
    func frameOfCell(pieChart: WCPieChart) -> CGRect
}

public class WCPieChart: UIView {
    /// connectting Delegate
    public weak var delegate: WCPieChartDelegate?
    /// connectting DataSource
    public weak var dataSource: WCPieChartDataSource? {
        didSet {
            delegate = dataSource as? WCPieChartDelegate
            setupDatasourceInfo()
        }
    }
    
    /// Pie chart start angle, should be in [-pi, pi)
    public var startAngle: CGFloat = CGFloat.pi / 2 {
        didSet {
            while startAngle >= CGFloat.pi {
                startAngle -= CGFloat.pi * 2
            }
            while startAngle < -CGFloat.pi {
                startAngle += CGFloat.pi * 2
            }
        }
    }
    
    var endAngle: CGFloat {
        return (CGFloat.pi * 2) + startAngle
    }
    
    // Outer radius
    var outerRadius: CGFloat = 36.0
    // Inner radius
    var innerRadius: CGFloat = 10.0
    // Offset of selected pie layer
    var selectedPieOffset: CGFloat = 5.0
    // Font of layer's description text
    var labelFont: UIFont = UIFont.systemFont(ofSize: 10)
    var showDescriptionText: Bool = false
    // animation duration
    var animationDuration: Double = 1.5
    // space slice
    var spaceSlice: CGFloat = 13.0
    // padding
    var padding: CGFloat = 10.0
    // set title label info height
    var titleHeight: CGFloat = 15.0
    // set space between title info and value info
    var spaceTitleAndValue: CGFloat = 8.0
    // set height of label value
    var valueHeight: CGFloat = 15.0
    // set space of each item
    var spaceValueAndTitle: CGFloat = 16.0
    
    var contentView: UIView!
    var contentPieView: UIView!
    
    var pieCenter: CGPoint {
        return CGPoint(x: (contentPieView.frame.width)/2, y: (contentPieView.frame.height)/2)
    }
    
    var strokeWidth: CGFloat {
        return outerRadius - innerRadius
    }
    
    var strokeRadius: CGFloat {
        return outerRadius
    }
    
    var selectedLayerIndex: Int = -1
    var total: Double = 0.0
    var refresh: Bool = true
    
    private func setupDatasourceInfo() {
        var tempHeight: CGFloat = 0.0
        let numberOfSlince = dataSource?.numberOfSlicesInPieChart(pieChart: self) ?? 0
        
        let cellFr = dataSource?.frameOfCell(pieChart: self) ?? CGRect.zero
        let xMainView = cellFr.origin.x
        let yMainView = cellFr.origin.y
        let wMainView = cellFr.width
        
        
        let spaceTop: CGFloat = spaceValueAndTitle
        tempHeight += spaceTop
        
        if numberOfSlince == 0 {
            tempHeight = 0.0
        } else if numberOfSlince == 1 {
            let centerOfContentPieView = cellFr.height/2
            let centerInfo = centerOfContentPieView - (titleHeight + spaceTitleAndValue + valueHeight)/2
            tempHeight = centerInfo
        }
        
        self.subviews.forEach { (subViw) in
            if subViw is UILabel {
                subViw.removeFromSuperview()
            }
        }
        
        for index in 0..<numberOfSlince {
            guard let pieValue = dataSource?.pieChart(pieChart: self, valueForSliceAtIndex: index) else { return }
            guard let pieColor = dataSource?.pieChart(pieChart: self, colorForSliceAtIndex: index) else { return }
            guard let pieTitle = dataSource?.pieChart(pieChart: self, titleForSliceAtIndex: index) else { return }
            let titleSt = "• \(pieTitle)"
            let dotRange = (titleSt as NSString).range(of: "•")
            let attributedString = NSMutableAttributedString(string: titleSt)
            let colorAttr = [
                NSAttributedString.Key.foregroundColor : pieColor,
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 23)
            ]
            attributedString.addAttributes(colorAttr, range: dotRange)
            let titleLb = UILabel()
            titleLb.font = UIFont.systemFont(ofSize: titleHeight)
            titleLb.attributedText = attributedString
            let titleX = wMainView / 2.0
            let widthTitle = wMainView - titleX
            let titleFr = CGRect(x: titleX, y: tempHeight, width: widthTitle, height: titleHeight+5)
            titleLb.frame = titleFr
            self.addSubview(titleLb)
            tempHeight += (titleHeight)
            
            tempHeight += spaceTitleAndValue
            
            //setup value amount
            let amountLb = UILabel()
            amountLb.font = UIFont.boldSystemFont(ofSize: valueHeight)
            amountLb.text = formatWonCurrency(amt: pieValue, currencyType: "원")
            let widthValue = cellFr.width - titleX
            let amountFr = CGRect(x: titleX, y: tempHeight, width: widthValue, height: valueHeight+5)
            amountLb.frame = amountFr
            self.addSubview(amountLb)
            
            
            //setup button detail
            let detailBtnSpaceRight: CGFloat = 8.0
            let detailBtnWidth: CGFloat = (valueHeight + 5)
            let detailBtnHeight: CGFloat = detailBtnWidth
            let detailBtnX = (wMainView - detailBtnWidth) - (detailBtnWidth/2) - detailBtnSpaceRight
            let detaitFr = CGRect(x: detailBtnX, y: tempHeight, width: detailBtnWidth, height: detailBtnHeight)
            let detailBtn = UIButton(frame: detaitFr)
            detailBtn.setTitle(">", for: .normal)
            detailBtn.setTitleColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), for: .normal)
            detailBtn.layer.cornerRadius = (detailBtnHeight/2)
            detailBtn.layer.borderWidth = 0.3
            detailBtn.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            detailBtn.tag = index
            detailBtn.addTarget(self, action: #selector(detailClick(_:)), for: .touchUpInside)
            self.addSubview(detailBtn)
            
            tempHeight += (valueHeight)
            tempHeight += spaceValueAndTitle
        }
        
        
        if tempHeight < contentPieView.frame.height {
            self.frame = CGRect(x: xMainView, y: yMainView, width: wMainView, height: contentPieView.frame.height)
        } else {
            self.frame = CGRect(x: xMainView, y: yMainView, width: wMainView, height: tempHeight)
        }
        
         //return dynamic height to cell
        setupContentPieView()
    }
    
    @objc func detailClick(_ sender: UIButton) {
        guard let pieTitle = dataSource?.pieChart(pieChart: self, titleForSliceAtIndex: sender.tag) else { return }
        print("click at: ", pieTitle)
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
    
    func setDefaultValues() {
        self.clipsToBounds = true
        contentView = UIView(frame: self.frame)
        contentPieView = UIView()
        contentPieView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        contentPieView.backgroundColor = contentPieView.backgroundColor
        contentView.addSubview(contentPieView)
        addSubview(contentView)
    }
    
    private func setupContentPieView() {
        let cellFr = dataSource?.frameOfCell(pieChart: self) ?? CGRect.zero
        let box = outerRadius*2 + strokeWidth + padding*2
        let a = (cellFr.width/3)/2 - strokeWidth - padding
        let pieChartFrame = CGRect(x: a, y: cellFr.height/2 - box/2, width: box, height: box)
        contentPieView.frame = pieChartFrame
        reloadData()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.frame
    }
    // Stroke chart / update current chart
    public func reloadData() {
        let parentLayer: CALayer = contentPieView.layer
        /// Mutable copy of current pie layers on display
        var currentLayers: NSMutableArray!
        if parentLayer.sublayers == nil {
            currentLayers = NSMutableArray()
        } else {
            currentLayers = NSMutableArray(array: parentLayer.sublayers!)
        }
        var itemCount: Int = dataSource?.numberOfSlicesInPieChart(pieChart: self) ?? 0
        total = 0
        for index in 0 ..< itemCount {
            let value = dataSource?.pieChart(pieChart: self, valueForSliceAtIndex: index) ?? 0
            total += value
        }
        var diff = itemCount - currentLayers.count
        let layersToRemove: NSMutableArray = NSMutableArray()
        
        // Begin CATransaction, disable user interaction
        contentView.isUserInteractionEnabled = false
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock { () -> Void in
            // Remove unnecessary layers
            for obj in layersToRemove {
                let layerToRemove: CAShapeLayer = obj as! CAShapeLayer
                layerToRemove.removeFromSuperlayer()
            }
            layersToRemove.removeAllObjects()
            
            // Re-enable user interaction
            self.contentView.isUserInteractionEnabled = true
        }
        
        // Deselect layer
        if selectedLayerIndex != -1 {
            deselectLayerAtIndex(index: selectedLayerIndex)
        }
        
        // Check if datasource is valid, otherwise remove all layers from content view and show placeholder text, if any
        if itemCount == 0 || total <= 0 {
            itemCount = 0
            diff = -currentLayers.count
        }
        
        // If there are more new items, add new layers correpsondingly in the beginning, otherwise, remove extra layers from the end
        if diff > 0 {
            while diff != 0 {
                let newLayer = createPieLayer()
                parentLayer.insertSublayer(newLayer, at: 0)
                currentLayers.insert(newLayer, at: 0)
                diff -= 1
            }
        } else if diff < 0 {
            while diff != 0 {
                let layerToRemove = currentLayers.lastObject as! CAShapeLayer
                currentLayers.removeLastObject()
                layersToRemove.add(layerToRemove)
                updateLayer(layer: layerToRemove, atIndex: -1, strokeStart: 1, strokeEnd: 1)
                diff += 1
            }
        }
        
        var toStrokeStart: CGFloat = 0.0
        var toStrokeEnd: CGFloat = 0.0
        var currentTotal: Double = 0.0
        
        /// Update current layers with corresponding item
        for index: Int in 0 ..< itemCount {
            let currentValue: Double = dataSource?.pieChart(pieChart: self, valueForSliceAtIndex: index) ?? 0
            let layer = currentLayers[index] as! CAShapeLayer
            toStrokeStart = CGFloat(currentTotal / total)
            toStrokeEnd = CGFloat((currentTotal + abs(currentValue)) / total)
            updateLayer(layer: layer, atIndex: index, strokeStart: toStrokeStart, strokeEnd: toStrokeEnd)
            currentTotal += currentValue
        }
        CATransaction.commit()
    }
    
    // init and make up layer
    func createPieLayer() -> CAShapeLayer {
        let pieLayer = CAShapeLayer()
        pieLayer.fillColor = UIColor.clear.cgColor
        pieLayer.borderColor = UIColor.black.cgColor
        pieLayer.borderWidth = 100.0
        pieLayer.strokeStart = 0
        pieLayer.strokeEnd = 0
        return pieLayer
    }
    
    func createArcAnimationForLayer(layer: CAShapeLayer, key: String, toValue: AnyObject!) {
        let arcAnimation: CABasicAnimation = CABasicAnimation(keyPath: key)
        var fromValue: AnyObject!
        if key == "strokeStart" || key == "strokeEnd" { fromValue = 0 as AnyObject }
        
        if layer.presentation() != nil { fromValue = layer.presentation()!.value(forKey: key) as AnyObject }
        arcAnimation.fromValue = fromValue
        arcAnimation.toValue = toValue
        arcAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        layer.add(arcAnimation, forKey: key)
        layer.setValue(toValue, forKey: key)
    }
    
    // draw line from start point to end point
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, parentLayer: CALayer) {
        //design the path
        parentLayer.sublayers?.forEach({ (eachLayer) in
            if eachLayer is CAShapeLayer {
                if let subLayerArr = parentLayer.sublayers, subLayerArr.count > 1 {
                    parentLayer.sublayers?.removeAll()
                }
            }
        })
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = spaceSlice / 4
        parentLayer.addSublayer(shapeLayer)
    }
    
    private func setupTextInfoInSlice(index: Int, myLayer: CAShapeLayer, strokeStart: CGFloat, strokeEnd: CGFloat) {
        var textLayer: CATextLayer!
        if myLayer.sublayers != nil {
            textLayer = layer.sublayers!.first as? CATextLayer
        } else {
            textLayer = CATextLayer()
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.isWrapped = true
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            myLayer.addSublayer(textLayer)
        }
        textLayer.font = CGFont(labelFont.fontName as CFString)
        textLayer.fontSize = labelFont.pointSize
        textLayer.string = ""
        
        if showDescriptionText && index >= 0 {
            textLayer.string = dataSource?.pieChart(pieChart: self, titleForSliceAtIndex: index)
        }
        
        let size: CGSize = (textLayer.string! as AnyObject).size(withAttributes: [NSAttributedString.Key.font: labelFont])
        textLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        if (strokeEnd - strokeStart) * CGFloat.pi * 2 * strokeRadius < max(size.width, size.height) {
            textLayer.string = ""
        }
        
        
        
        let midAngle: CGFloat = (strokeStart + strokeEnd) * CGFloat.pi + startAngle
        textLayer.position = CGPoint(x: pieCenter.x + strokeRadius * cos(midAngle),y: pieCenter.y + strokeRadius * sin(midAngle))
    }
    
    func updateLayer(layer: CAShapeLayer, atIndex index: Int, strokeStart: CGFloat, strokeEnd: CGFloat) {
        // Add animation to stroke path (in case radius changes)
        let path = UIBezierPath(arcCenter: pieCenter, radius: strokeRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        createArcAnimationForLayer(layer: layer, key: "path", toValue: path.cgPath)
        layer.lineWidth = strokeWidth
        
        // Assign stroke color by data source
        if index >= 0 { layer.strokeColor = dataSource?.pieChart(pieChart: self, colorForSliceAtIndex: index).cgColor }
        let rawSpace: CGFloat = 0//spaceSlice / 2000
        
        createArcAnimationForLayer(layer: layer, key: "strokeStart", toValue: (strokeStart + rawSpace/2) as AnyObject)
        createArcAnimationForLayer(layer: layer, key: "strokeEnd", toValue: (strokeEnd - rawSpace/2) as AnyObject)
        
        //************ Custom text layer for description, today 24.04.2019 textlayer not apply yet
        //setupTextInfoInSlice(index: index, myLayer: layer, strokeStart: strokeStart, strokeEnd: strokeEnd)
        //********************* end setting text layer
        
        // add fit line break slice
        let extraSpaceLine: CGFloat = 1.0
        if (dataSource?.numberOfSlicesInPieChart(pieChart: self) ?? 0) > 1 { //line number of slices start from 2 => work
            let startStrokeAngle: CGFloat = (strokeStart) * (CGFloat.pi*2) + startAngle
            let endStrokeAngle: CGFloat = (strokeEnd) * (CGFloat.pi*2) + startAngle
            let pointTargetStart = CGPoint(x: (pieCenter.x + (extraSpaceLine + outerRadius + strokeWidth/2) * cos(startStrokeAngle)),y: (pieCenter.y + (extraSpaceLine + outerRadius + strokeWidth/2) * sin(startStrokeAngle)))
            let pointTargetEnd = CGPoint(x: (pieCenter.x + (extraSpaceLine + outerRadius + strokeWidth/2) * cos(endStrokeAngle)),y: (pieCenter.y + (extraSpaceLine + outerRadius + strokeWidth/2) * sin(endStrokeAngle)))
            
            let pointTargetStartIn = CGPoint(x: (pieCenter.x + (-extraSpaceLine + innerRadius + strokeWidth/2) * cos(startStrokeAngle)),y: (pieCenter.y + (-extraSpaceLine + innerRadius + strokeWidth/2) * sin(startStrokeAngle)))
            let pointTargetEndIn = CGPoint(x: (pieCenter.x + (-extraSpaceLine + innerRadius + strokeWidth/2) * cos(endStrokeAngle)),y: (pieCenter.y + (-extraSpaceLine + innerRadius + strokeWidth/2) * sin(endStrokeAngle)))
            
            drawLineFromPoint(start: pointTargetStartIn, toPoint: pointTargetStart, ofColor: UIColor.white, parentLayer: layer)
            drawLineFromPoint(start: pointTargetEndIn, toPoint: pointTargetEnd, ofColor: UIColor.white, parentLayer: layer)
        } else {
            //delete when number of slice under 2
            layer.sublayers?.forEach({ (eachLayer) in
                if eachLayer is CAShapeLayer { eachLayer.removeFromSuperlayer() }
            })
        }
    }
    
    public func selectLayerAtIndex(index: Int) {
        let numberOfSlice = dataSource?.numberOfSlicesInPieChart(pieChart: self) ?? 0
        if numberOfSlice < 2 { return }
        let currentPieLayers = contentPieView.layer.sublayers
        if currentPieLayers != nil && index < currentPieLayers!.count {
            let layerToSelect = currentPieLayers![index] as! CAShapeLayer
            let currentPosition = layerToSelect.position
            let midAngle = (layerToSelect.strokeEnd + layerToSelect.strokeStart) * CGFloat.pi + startAngle
            let newPosition = CGPoint(x: currentPosition.x + selectedPieOffset * cos(midAngle), y: currentPosition.y + selectedPieOffset * sin(midAngle))
            layerToSelect.position = newPosition
            selectedLayerIndex = index
        }
    }
    
    public func deselectLayerAtIndex(index: Int) {
        let currentPieLayers = contentPieView.layer.sublayers
        if currentPieLayers != nil && index < currentPieLayers!.count {
            let layerToSelect = currentPieLayers![index] as! CAShapeLayer
            layerToSelect.position = CGPoint(x: 0, y: 0)
            layerToSelect.zPosition = 0
            selectedLayerIndex = -1
        }
    }
    
    func getSelectedLayerIndexOnTouch(touch: UITouch) -> Int {
        var selectedIndex = -1
        let currentPieLayers = contentPieView.layer.sublayers
        if currentPieLayers != nil {
            let point = touch.location(in: contentPieView)
            for i in 0 ..< currentPieLayers!.count {
                let pieLayer = currentPieLayers![i] as! CAShapeLayer
                let pieStartAngle = pieLayer.strokeStart * CGFloat.pi * 2
                let pieEndAngle = pieLayer.strokeEnd * CGFloat.pi * 2
                var angle = atan2(point.y - pieCenter.y, point.x - pieCenter.x) - startAngle
                if angle < 0 { angle += CGFloat.pi * 2 }
                let distance = sqrt(pow(point.x - pieCenter.x, 2) + pow(point.y - pieCenter.y, 2))
                if angle > pieStartAngle && angle < pieEndAngle && distance < outerRadius + strokeWidth/2 && distance > (innerRadius + strokeWidth/2) { selectedIndex = i }
            }
        }
        return selectedIndex
    }
    
    func handleLayerSelection(fromIndex: Int, toIndex: Int) {
        if fromIndex == -1 && toIndex != -1 {
            selectLayerAtIndex(index: toIndex)
            delegate?.pieChart(pieChart: self, itemSelectedAtIndex: toIndex)
        } else if fromIndex != -1 {
            deselectLayerAtIndex(index: fromIndex)
            delegate?.pieChart(pieChart: self, itemDeselectedAtIndex: fromIndex)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch: UITouch = touches.first! as UITouch
        let selectedIndex = getSelectedLayerIndexOnTouch(touch: anyTouch)
        handleLayerSelection(fromIndex: self.selectedLayerIndex, toIndex: selectedIndex)
    }
    
    override public init(frame: CGRect) {
        super.init(frame:frame)
        setDefaultValues()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setDefaultValues()
    }
}

// Pie chart data item
public class PieChartItem {
    
    var value: Double = 0.0
    var color: UIColor = UIColor.black
    var description: String?
    
    public init(value: Double, color: UIColor, description: String?) {
        self.value = value
        self.color = color
        self.description = description
    }
}

