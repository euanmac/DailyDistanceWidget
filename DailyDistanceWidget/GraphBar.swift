//
//  GraphBar.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 11/12/2020.
//

import SwiftUI

struct GraphDatePoint {
    let date: Date
    let value: Float
}

struct GraphData {
    
    let data: [GraphDatePoint]
    let maxDate: Date?
    let minDate: Date?
    let maxValue: Float
    let minValue: Float
    var maxTicks: Float = 10
    
    init (data: [GraphDatePoint]) {
        self.data = data
        self.maxDate = data.max {$0.date < $1.date}?.date
        self.minDate = data.min {$0.date > $1.date}?.date
        self.maxValue = data.max {$0.value < $1.value}?.value ?? 0
        self.minValue = data.max {$0.value > $1.value}?.value ?? 0
    }


        
    public var valueTickSpacing: Float {
        niceNum(range: valueScaleRange / (maxTicks - 1), round: true)
    }
    
    public var valueScaleRange: Float {
        niceNum(range: maxValue - minValue, round: false)
    }
    
    public var valueScaleMin: Float {
        (minValue / valueTickSpacing).rounded(.down) * valueTickSpacing
    }
    
    public var valueScaleMax: Float {
        (maxValue / valueTickSpacing).rounded(.up) * valueTickSpacing
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
            
        } else {
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
        
        let barHeightPerUnit = rect.height / CGFloat(graphData.valueScaleMax - graphData.valueScaleMin)
        let barWidth = rect.width / CGFloat(graphData.data.count)
        
        var path = Path()
        

        for (n, point) in graphData.data.enumerated() {
            
            let origin = CGPoint(x: CGFloat(n) * barWidth, y: 0)
            let size = CGSize(width: barWidth, height: barHeightPerUnit * CGFloat(point.value))
            path.addRect(CGRect(origin: origin, size: size))
        }
        let transform = CGAffineTransform(scaleX: 1, y: -1)
        
        return path.applying(transform.translatedBy(x: 0, y: rect.height * -1))
    }
}

struct GraphBar_Previews: PreviewProvider {
    
    static var data: [GraphDatePoint] = {
        let startDate = Date().startOfDay
        var _data =  Array(0...23).map {GraphDatePoint(date: startDate.byAdding(hours: $0), value: 0)}
        
        _data[1] = GraphDatePoint(date: startDate.byAdding(hours: 0), value: 37)
        _data[2] = GraphDatePoint(date: startDate.byAdding(hours: 1), value: 22.7)
        _data[7] = GraphDatePoint(date: startDate.byAdding(hours: 7), value: 2.5)
        _data[12] = GraphDatePoint(date: startDate.byAdding(hours: 12), value: 0.2)
        _data[18] = GraphDatePoint(date: startDate.byAdding(hours: 18), value: 1.3)
        return _data
    }()
 
    
    static var previews: some View {
        let graphData = GraphData(data: data)
        VStack {
            HStack {
                VStack {
                    Text("X")
                    Text("Min \(graphData.minDate!.shortTime)")
                    Text("Max \(graphData.maxDate!.shortTime)")
                }.frame(alignment: .top)
                VStack {
                    Text("Y")
                    Text("Min \(graphData.valueScaleMin)")
                    Text("Max \(graphData.valueScaleMax)")
                    Text("Range \(graphData.valueScaleRange)")
                    Text("Tick \(graphData.valueTickSpacing)")
                }.frame(alignment: .top)
            }
            HStack {
                GeometryReader {geo in
                    HStack {
                        GraphValueAxis(data: graphData)
                            .frame(width: geo.size.width * 0.05, height: geo.size.height, alignment: .trailing)
                        ZStack {
                            
                            GraphBar(data: graphData)
                                .fill(Color.blue)
                                
                            GraphPlotArea(data: graphData)
                                .stroke(Color.gray)
                        }
                    }
                }
            }
            .frame(width: 300, height: 300)
            
        }
            
    }
}

//struct GraphBarChart: View {
//    let graphData: GraphData
//
//    var body: some View {
//        ZStack {
//            GraphBar(data: graphData)
//                .fill(Color.blue)
//                .border(Color.black)
//        }
//    }
//}

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

