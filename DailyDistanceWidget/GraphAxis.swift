//
//  GraphAxis.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 23/12/2020.
//

import Foundation
import SwiftUI

struct GraphValueAxis: View {
    
    @State var maxLabelWidth: CFloat = 0
    let graphData: GraphData
    let scale: [String]
    
    init(data: GraphData) {
        self.graphData = data
        //let range =  - graphData.valueScaleMin
        //Init an array containing the scale  values
        self.scale = stride(from: graphData.valueScaleMin, through:((graphData.valueScaleMax)), by: graphData.valueTickSpacing).reversed().map( {String($0)})
    }
    
    @State var widthScale: CGFloat = 1
    @State var adjusted = false
   
    var body: some View {
        //let tickHeight = geo.size.height / CGFloat(range)
        GeometryReader {geo in
            VStack {
                Text("Scale \(widthScale)")
                    .fixedSize()
                ZStack {
                    ForEach(scale.indices) {scaleIndex in
                        Text(scale[scaleIndex])
                            .padding(0)
                            .scaleEffect(widthScale)
                            .lineLimit(1)
                            //.minimumScaleFactor(0.5)
                            .fixedSize(horizontal: true, vertical: true)
                            
                            .anchorPreference(key: SizePreferenceKey.self, value: .bounds, transform: {
                                                [scaleIndex: geo[$0].size] }
                            )
                            .border(Color.black)
                            .position(x: 1, y: (geo.size.height / CGFloat(scale.count - 1)) * CGFloat(scaleIndex))
        
                        
                    }
                    

                }
                .border(Color.black)
                .onPreferenceChange(SizePreferenceKey.self) { prefs in
                        print(prefs.count)
                        if !adjusted {
                            if let maxWidth = prefs.map {$1.width} .max(by: <) {
                                widthScale =  (geo.size.width / maxWidth)
                                adjusted = true
                            }
                        }
                    
                }
                
            }
//
//                .onbackgroundPreferenceChange(AxisLabelPreferenceKey.self, perform: { prefs in
//                        //max width
//                        let maxWidth = prefs.max(by: {geo[$0.bounds].width < geo[$1.bounds].width})
//        //                print("\(maxWidth)")
//                })
                
            
        }
    }
    
    func tickHeight(totalHeight: CGFloat) -> Float {
        return 0
        //totalHeight / graphData
    }
}


struct GraphAxis_Previews: PreviewProvider {
    
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
                GraphValueAxis(data: graphData)
                    .frame(width: 100 * 0.10, height: 300)
                
            }
            Spacer()
        }
        
        .border(Color.blue)
    }
    
}

struct AxisLabelPreferenceData: Equatable {
    
    let index: Int
    var bounds: CGSize
}

struct AxisLabelPreferenceKey: PreferenceKey {
    typealias Value = [AxisLabelPreferenceData]
    
    static var defaultValue: [AxisLabelPreferenceData] = []
    
    static func reduce(value: inout [AxisLabelPreferenceData], nextValue: () -> [AxisLabelPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

struct SizePreferences<Item: Hashable>: PreferenceKey {
    typealias Value = [Item: CGSize]

    static var defaultValue: Value { [:] }

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value.merge(nextValue()) { $1 }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGSize] = [:]
    static func reduce(value: inout [Int: CGSize] , nextValue: () -> [Int: CGSize]) {
        value.merge(nextValue()) { $1 }
    }
}
