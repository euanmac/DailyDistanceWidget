//
//  BarChartHorizontal.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 04/01/2021.
//

import SwiftUI

struct BarChartHorizontal: View {
    

    @State var grow = false
    @State var axisLabelScale: CGFloat = 1
    @State var barPercent:CGFloat = 0
    let data: GraphData
    let axisWidthRatio: CGFloat = 0.1
    let categoryScale = ["00", "06", "12", "18"]
    
    var body: some View {

        VStack {
            Button("Toggle") {barPercent = (barPercent == 1 ? 0 :1)}

            HStack {
                GeometryReader {geo in
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(spacing: 0){
                            GraphValueAxis(data: data, labelScale: $axisLabelScale)
                                .frame(width: geo.size.width * axisWidthRatio, alignment: .trailing)
                            ZStack {
                                
                                GraphPlotArea(data: data, categoryTicks: categoryScale.count)
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [2]))
                                
                                GraphBar(data: data, percent: barPercent)
                                    .fill(Color.black)
                                    .animation(.spring())
                                    
                            }
                            
                        }
                        GraphCategoryAxis(graphData: data, scale: categoryScale)
                            .frame(width: geo.size.width * (1 - axisWidthRatio), height: 30, alignment: .trailing)
                    }
                        
                }
            }
            .onAppear {
                barPercent = 1
            }
        }
    }
}

struct BarChartHorizontal_Previews: PreviewProvider {
    
    static var previews: some View {
        let graphData = GraphData.previewDataSet
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
                BarChartHorizontal(data: graphData)
                    .frame(width: 300, height: 300)
            }
        }
    }
}
