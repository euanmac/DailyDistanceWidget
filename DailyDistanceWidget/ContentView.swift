//
//  ContentView.swift
//  DailyDistanceWidget
//
//  Created by Euan Macfarlane on 18/11/2020.
//

import SwiftUI
import WidgetKit
import HealthKit


struct ContentView2: View {
    static var data: [GraphDatePoint] = {
        let startDate = Date().startOfDay
        var _data =  Array(0...23).map {GraphDatePoint(date: startDate.byAdding(hours: $0), value: 0)}
        
        _data[1] = GraphDatePoint(date: startDate.byAdding(hours: 0), value: 337)
        _data[2] = GraphDatePoint(date: startDate.byAdding(hours: 1), value: 22.7)
        _data[7] = GraphDatePoint(date: startDate.byAdding(hours: 7), value: 2.5)
        _data[12] = GraphDatePoint(date: startDate.byAdding(hours: 12), value: 0.2)
        _data[18] = GraphDatePoint(date: startDate.byAdding(hours: 18), value: 1.3)
        return _data
    }()
    
    var body: some View {
        let graphData = GraphData(data: ContentView2.data)
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
                GraphValueAxis(data: graphData)
                    .frame(width: 300 * 0.1, height: 300, alignment: .trailing)
            }
        }
        .frame(width: 300, height: 300)
    }
    
    
}

struct ContentView: View {
    
    enum AuthorisationState {
        case authorising, authorised, notAuthorised
    }
    
    let healthStore = HKHealthStore()
    let allTypes = Set([HKObjectType.workoutType(),
//                        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
//                        HKObjectType.quantityType(forIdentifier: .heartRate)!])
    
    @State var authState = AuthorisationState.authorising
    
    @State var distance = 0.0
    @State var distanceStats = [DistanceData]()
    
    var body: some View {
        
        if authState == .authorising {
            healthStore.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        authState = .authorised
                        healthStore.execute(distanceQuery)
                        healthStore.execute(observerQuery)
                        healthStore.execute(distanceByHourQuery)
                    } else {
                        authState = .notAuthorised
                    }
                }
            }
        }
        
        return
            VStack {
                HStack {
                    switch authState {
                        case .authorised:
                            VStack {
                                Text("Distance today: \(distance)")
                                ForEach(distanceStats, id: \.date) {stat in
                                    HStack {
                                        Text(stat.date.description)
                                        Text(stat.distance.description)
                                    }
                                }
                                CumDistanceGraph(dayDistancesByDate: distanceStats)
                                    .frame(width: 300, height: 300)
                            }
                                
                        case .notAuthorised:
                            Text("Could not read health data")
                        case .authorising:
                            Text("Reading data")
                    }
                }
                Button("Reload Widget", action: reloadWidget)
            }
            
    }
    
    func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "DailyDistance")

    }
    
    
    var observerQuery: HKObserverQuery {
        
        guard let distanceType =  HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else { fatalError("*** Unable to get the distance type ***")
        }
        
        let query = HKObserverQuery(sampleType: distanceType, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                // Properly handle the error.
                return
            }
                
            // Take whatever steps are necessary to update your app.
            // This often involves executing other queries to access the new data.
            healthStore.execute(distanceQuery)
            
            // If you have subscribed for background updates you must call the completion handler here.
            // completionHandler()
        }
        return query
    }
    
    var distanceQuery: HKStatisticsQuery {
        
        guard let distanceType =  HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else { fatalError("*** Unable to get the distance type ***") }
        
        let calendar = NSCalendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)

        guard let startDate = calendar.date(from: components) else {
            fatalError("*** Unable to create the start date ***")
        }
         
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
            fatalError("*** Unable to create the end date ***")
        }

        let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: today, options: .cumulativeSum) { (query, statisticsOrNil, errorOrNil) in
            
            guard let statistics = statisticsOrNil else {
                // Handle any errors here.
                return
            }
            
            let sum = statistics.sumQuantity()
            let totalDistance = sum?.doubleValue(for: HKUnit.meter())
            
            // Update your app here.
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            
            DispatchQueue.main.async {
                distance = totalDistance!
            }
        }
        
        
        return query

    }
    
    
    
    var distanceByHourQuery: HKStatisticsCollectionQuery {
        
        guard let distanceType =  HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else {
            fatalError("*** Unable to get the distance type ***")
        }
        let startDate = Date().startOfDay
        let interval = DateComponents(hour: 1)
        
        let query = HKStatisticsCollectionQuery(quantityType: distanceType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: interval)
         
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            var stats = [DistanceData]()
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            
            let endDate = startDate.endOfDay
            
            // Plot the weekly step counts over the past day
            statsCollection.enumerateStatistics(from: startDate, to: endDate) {statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.meter())
                    
                    stats.append(DistanceData(date: date, distance: Measurement(value: value, unit: UnitLength.meters)))
                   
                    }
            }
            
            DispatchQueue.main.async {
                distanceStats = stats
            }
  
        }
        
        return query
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



func handler(query: HKActivitySummaryQuery, summariesOrNil: [HKActivitySummary]?, errorOrNil: Error?) -> Void {
    
    guard let summaries = summariesOrNil else {
        // Handle any errors here.
        return
    }
    
    for summary in summaries {
        print(summary)
    }
    
    // The results come back on an anonymous background queue.
    // Dispatch to the main queue before modifying the UI.
    
    DispatchQueue.main.async {
        // Update the UI here.
    }
}


extension Date {

    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
   }

    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
    
    func byAdding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
    var shortTime: String {
        let df = DateFormatter()
        df.timeStyle = .short
        return df.string(from: self)
    }
    var shortDate: String {
        let df = DateFormatter()
        df.dateStyle = .short
        return df.string(from: self)
    }
}
