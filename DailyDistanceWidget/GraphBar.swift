//
//  GraphBar.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 11/12/2020.
//

import SwiftUI

struct GraphBarView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct GraphDataPoint {
    let xValue: Float
    let yValue: Float
}

struct GraphData {
    let data: [GraphDataPoint]
    let maxX: Float
    let minX: Float
    let maxY: Float
    let minY: Float
    var maxTicks: Float = 10
    
    init (data: [GraphDataPoint]) {
        self.data = data
        self.maxX = data.max {$0.xValue < $1.xValue}?.xValue ?? 0
        self.minX = data.min {$0.xValue > $1.xValue}?.xValue ?? 0
        self.maxY = data.max {$0.yValue < $1.yValue}?.yValue ?? 0
        self.minY = data.max {$0.yValue > $1.yValue}?.yValue ?? 0
    }

    public var xTickSpacing: Float {
        niceNum(range: xScaleRange / (maxTicks - 1), round: true)
    }
    
    public var xScaleRange: Float {
        niceNum(range: maxX - minX, round: false)
    }
    
    public var xScaleMin: Float {
        (minX / xTickSpacing).rounded(.down) * xTickSpacing
    }
    
    public var xScaleMax: Float {
        (maxX / xTickSpacing).rounded(.up) * xTickSpacing
    }
    
    public var yTickSpacing: Float {
        niceNum(range: yScaleRange / (maxTicks - 1), round: true)
    }
    
    public var yScaleRange: Float {
        niceNum(range: maxY - minY, round: false)
    }
    
    public var yScaleMin: Float {
        (minY / yTickSpacing).rounded(.down) * yTickSpacing
    }
    
    public var yScaleMax: Float {
        (maxY / yTickSpacing).rounded(.up) * yTickSpacing
    }
    
    
    /**
    * Returns a "nice" number approximately equal to range Rounds
    * the number if round = true Takes the ceiling if round = false.
    *
    * @param range the data range
    * @param round whether to round the result
    * @return a "nice" number to be used for the data range
    */
    private func niceNum(range: Float, round: Bool) -> Float {
    
        var niceFraction : Float /** nice, rounded fraction */
        let exponent = (log10(range)).rounded(.down) /** exponent of range */
        let fraction = range /  pow(10, exponent) /** fractional part of range */

        if (round) {
            switch fraction {
            case ..<1.5:
                niceFraction = 1
            case 1.5..<3:
                niceFraction = 2
            case 3..<7:
                niceFraction = 5
            default:
                niceFraction = 10
            }
//            if (fraction < 1.5) {
//                niceFraction = 1
//            }
//            else if (fraction < 3) {
//                niceFraction = 2
//            }
//            else if (fraction < 7) {
//                niceFraction = 5
//            }
//            else {
//                niceFraction = 10
//            }
            
        } else {
//            if (fraction <= 1) {
//                niceFraction = 1
//            }
//            else if (fraction <= 2) {
//                niceFraction = 2
//            }
//            else if (fraction <= 5) {
//                niceFraction = 5
//            }
//            else {
//                niceFraction = 10
//            }
            switch fraction {
            case ...1:
                niceFraction = 1
            case ...2:
                niceFraction = 2
            case ...5:
                niceFraction = 5
            default:
                niceFraction = 10
            }
        }

        return niceFraction * pow(10, exponent);
    }

    
    
    
}

struct GraphBar: Shape {
        
    let graphData: GraphData
    
    init(data: GraphData) {
        self.graphData = data
    }

    func path(in rect: CGRect) -> Path {
        
        let barHeightPerUnit = rect.height / CGFloat(graphData.yScaleMax - graphData.yScaleMin)
        let barWidth = rect.width / CGFloat(graphData.data.count)
        
        var path = Path()
        

        for (n, point) in graphData.data.enumerated() {
            
            let origin = CGPoint(x: CGFloat(n) * barWidth, y: 0)
            let size = CGSize(width: barWidth, height: barHeightPerUnit * CGFloat(point.yValue))
            path.addRect(CGRect(origin: origin, size: size))
        }
        let transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return path.applying(transform.translatedBy(x: 0, y: rect.height * -1))
    }
}


struct GraphBar_Previews: PreviewProvider {
    
    static var data: [GraphDataPoint] = {
        var _data =  Array(0...23).map {GraphDataPoint(xValue: Float($0), yValue: 0)}
        _data[1] = GraphDataPoint(xValue: 0, yValue: 4.7)
        _data[2] = GraphDataPoint(xValue: 0, yValue: 4.7)
        _data[7] = GraphDataPoint(xValue: 7, yValue: 2.5)
        _data[12] = GraphDataPoint(xValue: 12, yValue: 0.2)
        _data[18] = GraphDataPoint(xValue: 18, yValue: 1.3)
        return _data
    }()
    
    static var previews: some View {
        
        GraphBar(data: GraphData(data: data))
            .fill(Color.blue)
            .border(Color.black)
            .frame(width: 300, height: 420)
        
    }
}



//public struct NiceScale {
//
//    private(set)  var minPoint: Float
//    private(set)  var maxPoint: Float
//    public  var maxTicks: Float = 10
//
////    private  var tickSpacing: Float
////    private  var range: Float
////    private  var niceMin: Float
////    private  var niceMax: Float
//
//    /**
//    * Instantiates a new instance of the NiceScale class.
//    *
//    * @param min the minimum data point on the axis
//    * @param max the maximum data point on the axis
//    */
//    public init( min: Float,  max: Float) {
//        self.minPoint = min
//        self.maxPoint = max
//
//        /**
//        * Calculate and update values for tick spacing and nice
//        * minimum and maximum data points on the axis.
//        */
////        self.range =
////        self.tickSpacing = niceNum(range: range / (maxTicks - 1), round: true)
////        self.niceMin =
////        self.niceMax =
//    }
//
//    public var tickSpacing: Float {
//        niceNum(range: range / (maxTicks - 1), round: true)
//    }
//
//    public var range: Float {
//        niceNum(range: maxPoint - minPoint, round: false)
//    }
//
//    public var scaleMin: Float {
//        ((minPoint / tickSpacing) * tickSpacing).rounded(.down)
//    }
//
//    public var scaleMax: Float {
//        ((maxPoint / tickSpacing) * tickSpacing).rounded(.up)
//    }
//
//    /**
//    * Returns a "nice" number approximately equal to range Rounds
//    * the number if round = true Takes the ceiling if round = false.
//    *
//    * @param range the data range
//    * @param round whether to round the result
//    * @return a "nice" number to be used for the data range
//    */
//    private func niceNum(range: Float, round: Bool) -> Float {
//
//
//        var niceFraction : Float /** nice, rounded fraction */
//        let exponent = (log10(range)).rounded(.down) /** exponent of range */
//        let fraction = range /  pow(10, exponent) /** fractional part of range */
//
//        if (round) {
//            if (fraction < 1.5) {
//                niceFraction = 1
//            }
//            else if (fraction < 3) {
//                niceFraction = 2
//            }
//            else if (fraction < 7) {
//                niceFraction = 5
//            }
//            else {
//                niceFraction = 10
//            }
//
//        } else {
//            if (fraction <= 1) {
//                niceFraction = 1
//            }
//            else if (fraction <= 2) {
//                niceFraction = 2
//            }
//            else if (fraction <= 5) {
//                niceFraction = 5
//            }
//            else {
//                niceFraction = 10
//            }
//        }
//
//        return niceFraction * pow(10, exponent);
//    }
//
//}

