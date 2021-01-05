//
//  GraphBar.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 11/12/2020.
//

import SwiftUI

struct GraphBar: Shape {
        
    let graphData: GraphData
    let spacing: CGFloat = 1
    
    init(data: GraphData) {
        self.graphData = data
    }

///    Draw Bars as path for each data point in the Graph data
///    Needs to be able to account for following scenarios:
///    -No graph data values at all
///    -All values are 0
///    -All values are the same
    
    func path(in rect: CGRect) -> Path {
        
        let range = graphData.valueScaleMax - graphData.valueScaleMin
        let barHeightPerUnit = range == 0 ? 0 : rect.height / CGFloat(range)
        
        let barWidth = rect.width / CGFloat(graphData.data.count)
        
        var path = Path()

        for (n, point) in graphData.data.enumerated() {

            let origin = CGPoint(x: CGFloat(n) * barWidth, y: 0)
            let size = CGSize(width: barWidth, height: barHeightPerUnit * CGFloat(point.value))
            path.addRect(CGRect(origin: origin, size: size))
        }
        
        let transform = CGAffineTransform(scaleX: 1, y: -1)
        let ret = path.applying(transform.translatedBy(x: 0, y: rect.height * -1))
        
        return ret
        
    }
}

struct GraphBar_Previews: PreviewProvider {
    
    @State static var grow = false
    
    static var previews: some View {

        let graphData = GraphData.zeroDataSet
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
                GraphBar(data: graphData)
                    .frame(width: 300, height: 300)
            }

        }
            
    }
}
