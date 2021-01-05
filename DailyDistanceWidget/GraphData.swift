//
//  GraphData.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 05/01/2021.
//

import Foundation

struct GraphDatePoint {
    let date: Date
    let value: Double
}

struct GraphData {
    
    let data: [GraphDatePoint]
    let maxDate: Date?
    let minDate: Date?
    let maxValue: Double
    let minValue: Double
    var maxTicks: Double = 10
    
    init (data: [GraphDatePoint]) {
        self.data = data
        self.maxDate = data.max {$0.date < $1.date}?.date
        self.minDate = data.min {$0.date < $1.date}?.date
        self.maxValue = data.max {$0.value < $1.value}?.value ?? 0
        self.minValue = data.min {$0.value < $1.value}?.value ?? 0
    }

    var valueTickSpacing: Double {
        //default tick spacing to 1 if range is 0
        valueScaleRange != 0 ? niceNum(range: valueScaleRange / (maxTicks - 1), round: true) : 1
    }
    
    var valueScaleRange: Double {
        niceNum(range: maxValue - minValue, round: false)
    }
    
    var valueScaleMin: Double {
        (minValue / valueTickSpacing).rounded(.down) * valueTickSpacing
    }
    
    var valueScaleMax: Double {
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
    private func niceNum(range: Double, round: Bool) -> Double {
    
        var niceFraction : Double /** nice, rounded fraction */
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

extension GraphData {
    
    static var previewDataSet: GraphData = {
        let startDate = Date().startOfDay
        var _data =  Array(0...23).map {GraphDatePoint(date: startDate.byAdding(hours: $0), value: 0)}
        
        _data[1] = GraphDatePoint(date: startDate.byAdding(hours: 1), value: 1)
        _data[2] = GraphDatePoint(date: startDate.byAdding(hours: 2), value:2.2)
        _data[3] = GraphDatePoint(date: startDate.byAdding(hours: 3), value: 3.5)
        _data[5] = GraphDatePoint(date: startDate.byAdding(hours: 5), value: 6.2)
        _data[8] = GraphDatePoint(date: startDate.byAdding(hours: 8), value: 8.2)
        _data[10] = GraphDatePoint(date: startDate.byAdding(hours: 10), value: 11.3)
        _data[12] = GraphDatePoint(date: startDate.byAdding(hours: 12), value: 14.2)
        _data[18] = GraphDatePoint(date: startDate.byAdding(hours: 18), value: 5.3)
        return GraphData(data: _data)
    }()
    
    static var zeroDataSet: GraphData = {
        let startDate = Date().startOfDay
        var _data =  Array(0...23).map {GraphDatePoint(date: startDate.byAdding(hours: $0), value: 0)}
        return GraphData(data: _data)
    }()
    
    static var singleDataValue: GraphData = {
        let startDate = Date().startOfDay
        var _data =  Array(0...23).map {GraphDatePoint(date: startDate.byAdding(hours: $0), value: 0)}
        
        _data[1] = GraphDatePoint(date: startDate.byAdding(hours: 1), value: 1)
        _data[2] = GraphDatePoint(date: startDate.byAdding(hours: 2), value: 1)
        _data[3] = GraphDatePoint(date: startDate.byAdding(hours: 3), value: 1)
        _data[5] = GraphDatePoint(date: startDate.byAdding(hours: 5), value: 1)
        _data[8] = GraphDatePoint(date: startDate.byAdding(hours: 8), value: 1)
        _data[10] = GraphDatePoint(date: startDate.byAdding(hours: 10), value: 1)
        _data[12] = GraphDatePoint(date: startDate.byAdding(hours: 12), value: 1)
        _data[18] = GraphDatePoint(date: startDate.byAdding(hours: 18), value: 1)
        return GraphData(data: _data)
    }()
    
    static var largeDataValue: GraphData = {
        let startDate = Date().startOfDay
        var _data =  Array(0...23).map {GraphDatePoint(date: startDate.byAdding(hours: $0), value: 0)}
        
        _data[1] = GraphDatePoint(date: startDate.byAdding(hours: 1), value: 10000)
        _data[2] = GraphDatePoint(date: startDate.byAdding(hours: 2), value: 12222)
        _data[3] = GraphDatePoint(date: startDate.byAdding(hours: 3), value: 13333)
        _data[5] = GraphDatePoint(date: startDate.byAdding(hours: 5), value: 14444)
        _data[8] = GraphDatePoint(date: startDate.byAdding(hours: 8), value: 144454)
       
        return GraphData(data: _data)
    }()
}
