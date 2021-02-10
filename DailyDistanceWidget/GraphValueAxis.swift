//
//  GraphAxis.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 23/12/2020.
//

import Foundation
import SwiftUI

struct GraphValueAxis: View {
    
    @Binding var widthScale: CGFloat
    @State var adjusted = false
    @State var labelSizes = [Int: CGSize]()
    
    let axisColour: Color
    let graphData: GraphData
    let scale: [String]
    
    init(data: GraphData, labelScale: Binding<CGFloat>, axisColour: Color = .gray) {
        self.graphData = data
        self._widthScale = labelScale
        self.axisColour = axisColour
        
        
        //Init an array containing the scale valuesx
        let scaleValues = stride(from: graphData.valueScaleMin, through:((graphData.valueScaleMax)), by: graphData.valueTickSpacing).reversed().map( {$0})
        
        self.scale = scaleValues.map {String($0)}
        
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
                        ForEach(scale.indices, id: \.self) {scaleIndex in
                            
                            Text(scale[scaleIndex])
                                .font(.caption2)
                                //.border(Color.black)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: true)
                                .anchorPreference(key: SizePreferenceKey.self, value: .bounds, transform: {
                                        [scaleIndex: geo[$0].size] }
                                )
                                .anchorPreference(key: ScaleWidthPreferenceKey.self, value: .bounds, transform: {
                                        geo[$0].size.width }
                                )
                                .scaleEffect(widthScale)
                                .position(x: rightAlignment(labelIndex: scaleIndex, totalWidth: geo.size.width ), y: (divZeroHeight(height: geo.size.height, scaleSize: scale.count - 1) * CGFloat(scaleIndex)))

                        }


                    }


                    .onPreferenceChange(SizePreferenceKey.self) { sizes in
                        labelSizes = sizes
                    }
                    
                    .onPreferenceChange(ScaleWidthPreferenceKey.self) { maxWidth in
                        if !adjusted {
                            widthScale = min(CGFloat(1), geo.size.width / maxWidth)
                            adjusted = true
                        }
                    }
                }



                Rectangle()
                    .border(axisColour)
                    .frame(width: 1)
            }

    }
    
    func rightAlignment(labelIndex: Int, totalWidth: CGFloat) -> CGFloat {
        guard let size = labelSizes[labelIndex] else {
            return CGFloat.zero
        }
        
        return totalWidth - (size.width / CGFloat(2))
    }
    
    func tickHeight(totalHeight: CGFloat) -> Float {
        return 0
        //totalHeight / graphData
    }
}


struct GraphAxis_Previews: PreviewProvider {
    @State static var scale: CGFloat = 1
    static var previews: some View {
        let graphData = GraphData.largeDataValue
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
                GraphValueAxis(data: graphData, labelScale: $scale)
                    .frame(width: 100 * 0.5, height: 300)
                    .border(Color.red)
                
            }
            Spacer()
        }
        
        .border(Color.blue)
    }
    
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGSize] = [:]
    static func reduce(value: inout [Int: CGSize] , nextValue: () -> [Int: CGSize]) {
        value.merge(nextValue()) { $1 }
    }
}


struct ScaleWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat,
                       nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
