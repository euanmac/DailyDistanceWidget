//
//  GraphPlotArea.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 11/12/2020.
//

import SwiftUI

//struct GraphPlotAreaView: View {
//    var body: some View {
//        GraphPlotArea(maxScaleX: 10, minScaleX: 0, xInterval: 1, maxScaleY: 10, minScaleY: 0, yInterval: 1)
//    }
//}

struct GraphPlotArea: Shape {

    let graphData: GraphData
    
    init(data: GraphData) {
        self.graphData = data
    }
        
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        guard graphData.data.count > 0 else {
            return path
        }
        
        let range = graphData.valueScaleMax - graphData.valueScaleMin
        let intHeight = range == 0 ? 0 : rect.height / CGFloat(range)
        let intWidth = rect.width / CGFloat(graphData.data.count)
        
        
        for y in stride(from: graphData.valueScaleMin, through:((graphData.valueScaleMax)), by: graphData.valueTickSpacing) {
            path.move(to: CGPoint(x: 0, y: intHeight * CGFloat(y)))
            path.addLine(to: CGPoint(x: rect.width, y: intHeight * CGFloat(y)))
        }
        
//        for x in stride(from: 0, through:((range)), by: xInterval){
//
//            path.move(to: CGPoint(x: intWidth * CGFloat(x), y: 0))
//            path.addLine(to: CGPoint(x: intWidth * CGFloat(x), y: rect.height))
//        }
        
        return path
    }
}

struct GraphPlotArea_Previews: PreviewProvider {
    
    static var data: [GraphDatePoint] = {
        
        let startDate = Date().startOfDay
        var _data =  Array(0...23).map {GraphDatePoint(date: startDate.byAdding(hours: $0), value: 0)}
        
        _data[1] = GraphDatePoint(date: startDate.byAdding(hours: 0), value: 2.7)
        _data[2] = GraphDatePoint(date: startDate.byAdding(hours: 1), value: 4.7)
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
//                    Text("Range \(graphData.xScaleRange)")
//                    Text("Tick \(graphData.xTickSpacing)")
                }
                VStack {
                    Text("Y")
                    Text("Min \(graphData.valueScaleMin)")
                    Text("Max \(graphData.valueScaleMax)")
                    Text("Range \(graphData.valueScaleRange)")
                    Text("Tick \(graphData.valueTickSpacing)")
                }
            }
            GraphPlotArea(data: graphData)
                .stroke(Color.black)
                .frame(width: 200, height: 200)
        
        }
            
//        GraphPlotArea(maxScaleX: 24, minScaleX: 12, xInterval: 2, maxScaleY: 3000,minScaleY: 0, yInterval: 1000)
//            .stroke(Color.black)
//            .frame(width: 200, height: 200)
        
        
    }
}
