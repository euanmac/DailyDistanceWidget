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
    @State var widthScale: CGFloat = 1
    @State var adjusted = false
    let axisColour: Color

    let graphData: GraphData
    let scale: [String]
    
    init(data: GraphData, axisColour: Color = .gray) {
        self.graphData = data
        self.axisColour = axisColour
        
        //Init an array containing the scale valuesx
        self.scale = stride(from: graphData.valueScaleMin, through:((graphData.valueScaleMax)), by: graphData.valueTickSpacing).reversed().map( {String($0)})
    }
    
    //Ensure if only one value then
    func divZeroHeight(height: CGFloat, scaleSize: Int) -> CGFloat {
        if scaleSize == 0 {
            return CGFloat.zero
        } else {
            return (height / CGFloat(scaleSize))
        }
            
    }
    
    var body: some View {


            HStack(spacing: 1) {
                GeometryReader {geo in
                    ZStack {
                        ForEach(scale.indices) {scaleIndex in
                            Text(scale[scaleIndex])
                                
                                .lineLimit(1)
                                //.minimumScaleFactor(0.5)
                                .fixedSize(horizontal: true, vertical: true)
                                
                                .anchorPreference(key: SizePreferenceKey.self, value: .bounds, transform: {
                                                    [scaleIndex: geo[$0].size] }
                                )
                                .scaleEffect(widthScale)
                                .position(x: geo.size.width / 2, y: (divZeroHeight(height: geo.size.height, scaleSize: scale.count - 1) * CGFloat(scaleIndex)))
                                
                            
                        }

                    }
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
                
                Rectangle()
                    //.fill(axisColour)
                    .border(axisColour)
                    .frame(width: 1)
            }
        
    }
    
    func tickHeight(totalHeight: CGFloat) -> Float {
        return 0
        //totalHeight / graphData
    }
}


struct GraphAxis_Previews: PreviewProvider {
        
    static var previews: some View {
        let graphData = GraphData.singleDataValue
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
                    .frame(width: 100 * 0.25, height: 300)
                
            }
            Spacer()
        }
        
        .border(Color.blue)
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
