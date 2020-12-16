//
//  CumDistanceGraph.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 05/12/2020.
//

import SwiftUI

struct DistanceData {

    let date: Date
    let distance: Measurement<Unit>
}

struct CumDistanceGraph: View {
    
    let dayDistancesByDate: [DistanceData]
    let cumDistanceByHour: [(hour: Int, distance: Measurement<Unit>)]
    let maxAxisVal: Double
    
    init (dayDistancesByDate: [DistanceData]) {

        self.dayDistancesByDate = dayDistancesByDate
        
        self.cumDistanceByHour = (0..<24).map {i in
            
            return (i,  dayDistancesByDate.filter {
                    Calendar.current.component(.hour, from: $0.date) <= i
                }
                .reduce(into: Measurement(value: 0, unit: UnitLength.meters)) {$0 = $0 + $1.distance})
        }
        
        self.maxAxisVal = max(cumDistanceByHour.last!.distance.value.rounded(.up), 3000)
        
    }
    
    var body: some View {

        GeometryReader { geo in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                
                GraphPlotArea(maxScaleX: 24, maxScaleY: 3)
                    .stroke(Color.gray)
                GraphCumDistanceBars(cumDistanceByHour: cumDistanceByHour, maxAxisVal: maxAxisVal, rect: geo.size)
                    .frame(width: geo.size.width, height: geo.size.height)
//                Rectangle()
//                    .stroke(Color.red)
//                    .frame(width: geo.size.width, height: geo.size.height)
                    
            }
        }
        
    }
    

}

struct GraphCumDistanceBars: View {
    let cumDistanceByHour: [(hour: Int, distance: Measurement<Unit>)]
    let maxAxisVal: Double
    let rect: CGSize
    
    var body: some View {
 
        HStack(alignment: .bottom, spacing: 5) {
            ForEach(cumDistanceByHour, id:\.self.0) {i  in
                VStack(alignment: .center) {
                    Capsule()
                        .frame(height: getBarLength(maxLength: rect.height, roundedMaxDistance: maxAxisVal, distance: i.distance))
                    }
                
            }
        }

    }
    
    private func getBarLength(maxLength: CGFloat, roundedMaxDistance: Double, distance: Measurement<Unit>) -> CGFloat {
        return CGFloat(distance.value) / CGFloat(roundedMaxDistance) * maxLength
    }
}

struct CumDistanceGraph_Previews: PreviewProvider {
    static var previews: some View {
        let d = DistanceData(date: Date(), distance: Measurement(value: 200, unit: UnitLength.meters))
        let d2 = DistanceData(date: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, distance: Measurement(value: 300, unit: UnitLength.meters))
        let d3 = DistanceData(date: Calendar.current.date(byAdding: .hour, value: -22, to: Date())!, distance: Measurement(value: 300, unit: UnitLength.meters))
        
        Group {
            CumDistanceGraph(dayDistancesByDate: [d,d2,d3])
                .frame(width: 300, height: 300)
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
        }
        
    }
}
