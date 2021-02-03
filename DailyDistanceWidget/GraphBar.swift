//
//  GraphBar.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 11/12/2020.
//

import SwiftUI

struct GraphBar: Shape {
        
    let graphData: GraphData
    let spacing: CGFloat = 2
    let rounded = true
    
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
        
        let barWidth = max(0, (rect.width / CGFloat(graphData.data.count)) - spacing)
        
        var path = Path()

        for (n, point) in graphData.data.enumerated() {

            let origin = CGPoint(x: CGFloat(n) * (barWidth + spacing), y: 0)
            
            //Adjust bar height
            let barHeight = max(0, barHeightPerUnit * CGFloat(point.value))

            let bar = CGRect(origin: origin, size: CGSize(width: barWidth, height:barHeight))
            
            let rounding = rounded ? (bar.width * 0.3) : 0
            path.addRoundedRect(in: bar, cornerSize: CGSize (width: rounding, height: rounding), style: .continuous, transform: .identity)
            
//            path.move(to: bar.origin)
//            path.addLine(to: CGPoint(x: bar.minX, y: bar.maxY))
//            if !roundedTop {
//                path.addLine(to: CGPoint(x: bar.maxX, y:bar.maxY))
//            } else {
//                path.addArc(center: CGPoint(x: bar.midX, y: bar.height), radius: bar.width / 2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
//            }
//            path.addLine(to: CGPoint(x: bar.maxX, y:bar.minY))
////            path.addLine(to:origin)
//            path.closeSubpath()
//
        }
        
        let transform = CGAffineTransform(scaleX: 1, y: -1)
        let ret = path.applying(transform.translatedBy(x: 0, y: rect.height * -1))
        
        return ret
        
    }
}

struct GraphBar_Previews: PreviewProvider {
    
    @State static var grow = false
    
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
                GraphBar(data: graphData)
                    .frame(width: 300, height: 300)
            }

        }
            
    }
}
