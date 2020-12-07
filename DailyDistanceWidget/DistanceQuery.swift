////
////  DistanceQuery.swift
////  DailyDistanceWidget
////
////  Created by Euan Macfarlane on 29/11/2020.
////
//
//import Foundation
//import HealthKit
//
//
//struct HealthKitHelper {
//    
//    static var healthStore = HKHealthStore()
//    static var distance: Double = 0.0
//    
//    static var observerQuery: HKObserverQuery {
//        
//        guard let distanceType =  HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else { fatalError("*** Unable to get the distance type ***")
//        }
//        
//        let query = HKObserverQuery(sampleType: distanceType, predicate: nil) { (query, completionHandler, errorOrNil) in
//            
//            if let error = errorOrNil {
//                // Properly handle the error.
//                return
//            }
//                
//            // Take whatever steps are necessary to update your app.
//            // This often involves executing other queries to access the new data.
//            healthStore.execute(distanceQuery)
//            
//            // If you have subscribed for background updates you must call the completion handler here.
//            // completionHandler()
//        }
//        return query
//    }
//
//    var distanceQuery: HKStatisticsQuery {
//        
//        guard let distanceType =  HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else { fatalError("*** Unable to get the distance type ***") }
//        
//        let calendar = NSCalendar.current
//        let now = Date()
//        let components = calendar.dateComponents([.year, .month, .day], from: now)
//
//        guard let startDate = calendar.date(from: components) else {
//            fatalError("*** Unable to create the start date ***")
//        }
//         
//        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
//            fatalError("*** Unable to create the end date ***")
//        }
//
//        let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
//        
//        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: today, options: .cumulativeSum) { (query, statisticsOrNil, errorOrNil) in
//            
//            guard let statistics = statisticsOrNil else {
//                // Handle any errors here.
//                return
//            }
//            
//            let sum = statistics.sumQuantity()
//            let totalDistance = sum?.doubleValue(for: HKUnit.meter())
//            
//            // Update your app here.
//            
//            // The results come back on an anonymous background queue.
//            // Dispatch to the main queue before modifying the UI.
//            
//            DispatchQueue.main.async {
//                distance = totalDistance!
//            }
//        }
//    
//        return query
//
//        }
//    }
