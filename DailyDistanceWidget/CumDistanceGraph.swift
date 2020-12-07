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
    
//    let day: [Date] = {
//        let interval = DateComponents(hour: 1)
//        let start = Date().startOfDay
//        return (0..<24).map {
//            Calendar.current.date(byAdding: .hour, value: $0, to: start)!
//        }
//    }()
    
    let dayDistancesByDate: [DistanceData]
    let cumDistanceByHour: [(hour: Int, distance: Measurement<Unit>)]
    var maxAxisVal = 0
    
    init (dayDistancesByDate: [DistanceData]) {

        self.dayDistancesByDate = dayDistancesByDate
        
        //Calculate sum of distance by hour of day and store
//        for i in (0..<24) {
//
//            //Find any distance where time is less than the hour
//            let validDistances = dayDistancesByDate.filter {
//                let hour = Calendar.current.component(.hour, from: $0.date)
//                return hour <= i
//            }
//
//            let sumToHour = validDistances.reduce(into: Measurement(value: 0, unit: UnitLength.meters)) {$0 = $0 + $1.distance}
//            cumDistanceByHour.append((i,sumToHour))
//        }
//
        self.cumDistanceByHour = (0..<24).map {i in
            
            return (i,  dayDistancesByDate.filter {
                    Calendar.current.component(.hour, from: $0.date) <= i
                }
                .reduce(into: Measurement(value: 0, unit: UnitLength.meters)) {$0 = $0 + $1.distance})
            
        }
        
        
    }
    
    
    
    
    var body: some View {

        GeometryReader { geo in
        
            ZStack {
                CumDistanceBars(cumDistanceByHour: cumDistanceByHour, rect: geo.size)
            }
            
        }
        
    }
    

}

struct CumDistanceBars: View {
    let cumDistanceByHour: [(hour: Int, distance: Measurement<Unit>)]
    let rect: CGSize
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(cumDistanceByHour, id:\.self.0) {i  in
                VStack() {
                    Capsule()
                        .frame(height: getBarLength(maxLength: rect.height, maxDistance: cumDistanceByHour.last!.distance, distance: i.distance))
                }
            }
        }
    }
    
    private func getBarLength(maxLength: CGFloat, maxDistance: Measurement<Unit>, distance: Measurement<Unit>) -> CGFloat {
        
        //round up max length to nearest 1km
        let roundedMaxDistance = maxDistance.value.rounded(.up)
        return CGFloat(distance.value) / CGFloat(roundedMaxDistance) * maxLength
    }
}

struct CumDistanceGraph_Previews: PreviewProvider {
    static var previews: some View {
        let d = DistanceData(date: Date(), distance: Measurement(value: 1000, unit: UnitLength.meters))
        let d2 = DistanceData(date: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, distance: Measurement(value: 3000, unit: UnitLength.meters))
        let d3 = DistanceData(date: Calendar.current.date(byAdding: .hour, value: -18, to: Date())!, distance: Measurement(value: 3000, unit: UnitLength.meters))
        
        
        CumDistanceGraph(dayDistancesByDate: [d,d2,d3])
            .frame(width: 300, height: 300)
            .border(Color.gray)
    }
}
