//
//  DailyDistance.swift
//  DailyDistance
//
//  Created by Euan Macfarlane on 26/11/2020.
//

import WidgetKit
import SwiftUI
import Intents
import HealthKit

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("placeholder")
        return SimpleEntry(date: Date(), distance: 0, configuration: ConfigurationIntent(), phase: "Placeholder")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        if context.isPreview {
            let entry = SimpleEntry(date: currentDate, distance: 0, configuration: configuration, phase: "Snapshot Preview")
            completion(entry)
            return
        }
        
        let query = getDistance { distance in

            let entry = SimpleEntry(date: currentDate, distance: distance, configuration: configuration, phase: "Snapshot")
    
            DispatchQueue.main.async {
                completion(entry)
            }
           
        }
        print("snapshot")
        HKHealthStore().execute(query)
    }

//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//
//        let query = getDistance { distance in
//
//            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//            let currentDate = Date()
//            for i in (0...4) {
//                let afterDate = Calendar.current.date(byAdding: .second, value: 20 * i, to: currentDate)!
//                let entry = SimpleEntry(date: afterDate, distance: Double(i) * 1000, configuration: configuration)
//                entries.append(entry)
//            }
//            let timeline = Timeline(entries: entries, policy: .atEnd) //.after(afterDate))
//            DispatchQueue.main.async {
//                completion(timeline)
//            }
//            print("reload")
//        }
//        HKHealthStore().execute(query)
//
//    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        let query = getDistance { distance in
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()

            //let afterDate = Calendar.current.date(byAdding: .second, value: 20, to: currentDate)!
            let entry = SimpleEntry(date: currentDate, distance: distance, configuration: configuration, phase: "Timeline")
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .atEnd)
            DispatchQueue.main.async {
                completion(timeline)
            }
            print("reload")
        }
        HKHealthStore().execute(query)
        
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let distance: Double
    let configuration: ConfigurationIntent
    let phase: String
}

struct DailyDistanceEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(distanceString2(metres: entry.distance))
                .bold()
                .font(.largeTitle)
            Text(dateString(for: entry.date))
                .font(.caption)
            Text(entry.phase)
                .font(.caption)
        }
    }
    
    func distanceString(metres distance: Double) -> String {
  
        let distanceFormatter = MeasurementFormatter()
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        return measurement.converted(to: .kilometers).description
        
    }
    
    func distanceString2(metres distance: Double) -> String {

        print(Locale.current.usesMetricSystem) //prints true
        print(Locale.current.identifier)
        print(Locale.current.description)

        let distanceFormatter = MeasurementFormatter()
        distanceFormatter.unitOptions = .providedUnit
        distanceFormatter.numberFormatter.maximumFractionDigits = 2
        distanceFormatter.unitStyle = .short
        let measurement = Measurement(value: distance, unit: UnitLength.meters).converted(to: .kilometers)

        return distanceFormatter.string(from: measurement)
    }
    
    func dateString(for date: Date) -> String {
   
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: date)
        
    }
}

@main
struct DailyDistance: Widget {
    let kind: String = "DailyDistance"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            DailyDistanceEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

extension Provider {
    
    func getDistance(handler: @escaping (Double) -> ()) -> HKStatisticsQuery {
            
        let defaults = UserDefaults.standard
        
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
                print(errorOrNil?.localizedDescription)
                let cached = defaults.double(forKey: "distance")
                handler(cached)
                return
            }
            
            let sum = statistics.sumQuantity()
            let totalDistance = sum?.doubleValue(for: HKUnit.meter())
            
            // Store in user defaults
            defaults.setValue(totalDistance, forKey: "distance")
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            handler(totalDistance ?? 0.0)
            
        }
        
        return query
    }
}



struct DailyDistance_Previews: PreviewProvider {
    static var previews: some View {
        DailyDistanceEntryView(entry: SimpleEntry(date: Date(), distance: 50.5, configuration: ConfigurationIntent(), phase: "Preview"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

