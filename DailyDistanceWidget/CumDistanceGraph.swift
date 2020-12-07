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
    
    let day: [Date] = {
        let interval = DateComponents(hour: 1)
        let start = Date().startOfDay
        return (0..<24).map {
            Calendar.current.date(byAdding: .hour, value: $0, to: start)!
        }
    }()
    
    let dayDistancesByDate: [DistanceData]
    var cumDayDistanceByDate = [DistanceData]()
    
    init (dayDistancesByDate: [DistanceData]) {
        self.dayDistancesByDate = dayDistancesByDate
        
        //Calculate cumulative distance by hour using the distance data
        for (i, distanceData) in dayDistancesByDate.enumerated() {
            
            let previousDistance = (i == 0) ? Measurement(value: 0, unit: UnitLength.meters) : dayDistancesByDate[i-0].distance
            
            let cumDistance =  distanceData.distance + previousDistance
            
            cumDayDistanceByDate.append(contentsOf: [DistanceData(date: distanceData.date, distance: cumDistance)])
        }
    
        var cumDistanceByHour = [(Int, Measurement<Unit>)]()
        for i in (0..<24) {
            
            //Find any distance where time is less than the hour
            let validDistances = dayDistancesByDate.filter {
                let hour = Calendar.current.component(.hour, from: $0.date)
                return hour <= i
            }
            
            let sumToHour = validDistances.reduce(into: Measurement(value: 0, unit: UnitLength.meters)) {$0 = $0 + $1.distance}
            cumDistanceByHour.append((i,sumToHour))
        }
        
        
    }
    
    var body: some View {
        HStack {
            ForEach(day, id:\.self) { hour in
                Capsule()
            }
        }
    }
}

struct CumDistanceGraph_Previews: PreviewProvider {
    static var previews: some View {
        let d = DistanceData(date: Date(), distance: Measurement(value: 1, unit: UnitLength.meters))
        let d2 = DistanceData(date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, distance: Measurement(value: 3, unit: UnitLength.meters))
        
        
        CumDistanceGraph(dayDistancesByDate: [d,d2])
    }
}
