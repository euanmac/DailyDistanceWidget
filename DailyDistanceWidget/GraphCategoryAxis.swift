//
//  GraphCategoryAxis.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 04/02/2021.
//

import SwiftUI

struct GraphCategoryAxis: View {
    
    @State var labelSizes = [Int: CGSize]()
    
    let graphData: GraphData
    let scale: [String]
    let axisColour: Color = .gray
    
    var body: some View {
        
        VStack(spacing: 1) {
            
            Rectangle()
                .fill(axisColour)
                .frame(height: 1)
            
            GeometryReader {geo in

                HStack(spacing: 0) {
                    
                    ForEach(scale.indices, id: \.self) {scaleIndex in
                        
                        Text(scale[scaleIndex])
                            .font(.caption2)
//                            .border(Color.black)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: true)
                            .anchorPreference(key: SizePreferenceKey.self, value: .bounds, transform: {
                                    [scaleIndex: geo[$0].size] }
                            )
                            .anchorPreference(key: ScaleWidthPreferenceKey.self, value: .bounds, transform: {
                                    geo[$0].size.width }
                            )
                            //.scaleEffect(widthScale)
//                            .position(x: geo.size.width / CGFloat(scale.count) * CGFloat(scaleIndex)  , y: 0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                    }

                }

                .onPreferenceChange(SizePreferenceKey.self) { sizes in
                    labelSizes = sizes
                }
            
                .onPreferenceChange(ScaleWidthPreferenceKey.self) { maxWidth in
//                    if !adjusted {
//                        widthScale = geo.size.width / maxWidth
//                        adjusted = true
//                    }
                }
            }
            
//            Rectangle()
//                .border(axisColour)
//                .frame(width: 1)
        }
    }
    
//    //Ensure if only one value then
//    func divZeroWidth(width: CGFloat, scaleSize: Int) -> CGFloat {
//        if scaleSize == 0 {
//            return CGFloat.zero
//        } else {
//            return (height / CGFloat(scaleSize))
//        }
//
//    }
}

struct GraphCategoryAxis_Previews: PreviewProvider {
    static var previews: some View {
        
        let graphData = GraphData.largeDataValue
        let scale = ["00", "06", "12", "18"]
        
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
                GraphCategoryAxis(graphData: graphData, scale: scale)
                    .border(Color.red)
                
            }
            Spacer()
        }
        
        .border(Color.blue)
    }
}
