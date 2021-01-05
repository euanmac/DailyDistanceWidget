//
//  BarChartHorizontal.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 04/01/2021.
//

import SwiftUI

struct BarChartHorizontal: View {
    

    @State var grow = false
    let data: GraphData
    
    var body: some View {

        VStack {
            Button("Toggle") {grow.toggle()}

            HStack {
                GeometryReader {geo in
                    HStack(spacing: 0){
                        GraphValueAxis(data: data)
                            .frame(width: geo.size.width * 0.075, height: geo.size.height, alignment: .trailing)
                        ZStack {
                            
                            GraphBar(data: data)
                                .trim(from: 0, to: grow ? 1 : 0 )
                                .fill(Color.blue)
                                .animation(.linear)
                                
                            GraphPlotArea(data: data)
                                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [2]))
                        }
                    }
                }
            }
            .onAppear {
                grow = true
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
