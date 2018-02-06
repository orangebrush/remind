//
//  StepManager.swift
//  RemindData
//
//  Created by gg on 19/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import HealthKit
import CoreMotion
public final class StepManager: NSObject {
    
    private var healthStore: HKHealthStore?
    
    
    //MARK:- class init *****************************************************************************************************
    struct singleton{
        static var instance = StepManager()
    }
    @discardableResult
    public class func share() -> StepManager{
        return singleton.instance
    }
    
    public override init() {
        super.init()
        
        //判断当前设备是否支持HeathKit
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }else{
            debugPrint("设备不支持HealthKit")
        }
    }
    
    ///请求权限
    public func request(){
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            ]
        //请求
        healthStore?.requestAuthorization(toShare: nil, read: healthKitTypesToRead) {
            success, error in
            guard success else{
                if let err = error {
                    debugPrint("error: \(err)")
                }
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "openStepRemiand"), object: nil)
            
            // UserDefaults.standard.set(true, forKey: "frist_step_notif")
            debugPrint("同意获取healthkit数据")
            
           
        }
    }
    
    public func isOpenHealthKit()->Bool{
        return  healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!) == .sharingAuthorized &&  healthStore?.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!) == .sharingAuthorized
    }
    
    
    //运动与健康内容
//    var pedonmeter: CMPedometer = CMPedometer()
    
    ///获取当前步数(今天)
    public func getStepsAndDistanceM(closure: @escaping (_ codeResult: CodeResult,_ daySteps: Int, _ distanceM: Int)->()){
        
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else{
            closure(.failure, 0, 0)
            return
        }
        
        //请求运动与健康
//        if CMPedometer.isStepCountingAvailable() {
//            let calendar = Calendar.current
//            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
//            components.hour = 0
//            components.minute = 0
//            components.second = 0
//
//            let startDate = calendar.date(from: components)
//            var endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
//            endComponents.hour = 23
//            endComponents.minute = 59
//            endComponents.second = 59
//            let endDate = calendar.date(from: endComponents)
//
//
//            pedonmeter.queryPedometerData(from: startDate!, to: endDate!, withHandler: { pedometerData, error in
//                if (error != nil) {
//                    print(error ?? "")
//                }else {
//                    print("步数" + "\(String(describing: pedometerData?.numberOfSteps))")
//                    print("距离" + "\(String(describing: pedometerData?.distance))")
//                }
//            })
//        }
        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: predicateForSamplesToday(), limit: HKObjectQueryNoLimit, sortDescriptors: [timeSortDescriptor]) { (query, results, error) in
            DispatchQueue.main.async {
                guard error == nil else{
                    closure(.failure, 0, 0)
                    return
                }
                
                guard let list = results else{
                    closure(.failure, 0, 0)
                    return
                }
                
                //统计步数
                var totalSteps = 0
                var totalStepsFromWatch = 0
                for sample in list{
                    let quantity = (sample as! HKQuantitySample).quantity
                    let step = quantity.doubleValue(for: HKUnit.count())
                    let startDate = (sample as! HKQuantitySample).startDate
                    let endDate = (sample as! HKQuantitySample).endDate
                    
                    let startComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                    let endComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
                    
                    if let deviceName = (sample as! HKQuantitySample).device?.name{
                        if deviceName == "Apple Watch" {
                            if startComponents.year! == endComponents.year! && startComponents.month! == endComponents.month! && startComponents.day! == endComponents.day!{
                                totalStepsFromWatch += Int(step)
                            }else{
                                totalStepsFromWatch += Int(step / 2)
                            }
                        }else if deviceName == "iPhone"{
                            if startComponents.year! == endComponents.year! && startComponents.month! == endComponents.month! && startComponents.day! == endComponents.day!{
                                totalSteps += Int(step)
                            }else{
                                totalSteps += Int(step / 2)
                            }
                        }
                    }
                }
                
                //获取距离
                self.getDistanceM(closure: { (totalDistanceM) in
                    DispatchQueue.main.async {
                        guard let totalDist = totalDistanceM else{
                            closure(.failure, 0, 0)
                            return
                        }
                        
                        closure(.success, max(totalStepsFromWatch, totalSteps), totalDist)
                    }
                })
            }
            
        }
        
        healthStore?.execute(query)
    }
    
    ///获取当前距离
    func getDistanceM(closure: @escaping (_ dayDistanceM: Int?)->()){
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else{
            closure(nil)
            return
        }
        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: distanceType, predicate: predicateForSamplesToday(), limit: HKObjectQueryNoLimit, sortDescriptors: [timeSortDescriptor]) { (query, results, error) in
            guard error == nil else{
                closure(nil)
                return
            }
            
            guard let list = results else{
                closure(nil)
                return
            }
            
            var totalMeter = 0
            var totalMeterFromWatch = 0
            for sample in list{
                let quantity = (sample as! HKQuantitySample).quantity
                let meter = quantity.doubleValue(for: HKUnit.meter())
                let startDate = (sample as! HKQuantitySample).startDate
                let endDate = (sample as! HKQuantitySample).endDate
                
                let startComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                let endComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
                
                if let deviceName = (sample as! HKQuantitySample).device?.name{
                    if deviceName == "Apple Watch" {
                        if startComponents.year! == endComponents.year! && startComponents.month! == endComponents.month! && startComponents.day! == endComponents.day!{
                            totalMeterFromWatch += Int(meter)
                        }else{
                            totalMeterFromWatch += Int(meter / 2)
                        }
                    }else if deviceName == "iPhone"{
                        if startComponents.year! == endComponents.year! && startComponents.month! == endComponents.month! && startComponents.day! == endComponents.day!{
                            totalMeter += Int(meter)
                        }else{
                            totalMeter += Int(meter / 2)
                        }
                    }
                }
            }
            
            closure(max(totalMeterFromWatch, totalMeter))
        }
        
        healthStore?.execute(query)
    }
    

    
    
    
    
    
    
    //获取多日——————————————————————————————————————————————————————————————————————————————————
    ///获取多日步数距离列表
    public func getStepsListAndDistanceMList(byLastDays lastdays: Int, closure: @escaping (_ codeResult: CodeResult,_ dayStepsDistanceMList: [(Date, Int, Int)])->()){
        
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else{
            closure(.failure, [])
            return
        }
        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        
        let predicate = predicateForSamples(byDays: lastdays)
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [timeSortDescriptor]) { (query, results, error) in
            guard error == nil else{
                DispatchQueue.main.async {
                    closure(.failure, [])
                }
                return
            }
            
            guard let list = results, !list.isEmpty else{
                DispatchQueue.main.async {
                    //未开启权限则从网络获取
                    let endDate = Date()
                    let beginDate = endDate.offset(with: -lastdays + 1)
                    DataManager.share().getStepsDetailLogList(withBeginDate: beginDate, withEndDate: endDate, closure: { (codeResult, message, stepModelList) in
                        guard codeResult == .success else{
                            closure(.failure, [])
                            return
                        }
                        var result = [(Date, Int, Int)]()
                        for i in 0..<lastdays{
                            guard i < stepModelList.log.count else{
                                continue
                            }
                            let stepModel = stepModelList.log[i]
                            result.append((stepModel.date, stepModel.step, stepModel.distanceM))
                        }
                        closure(.success, result)
                    })
                }
                return
            }
            
            //统计步数
            var resultList = [(Date, Int, Int)]()
            
            let calendar = Calendar.current
            var tempYear = 0
            var tempMonth = 0
            var tempDay = 0
            var tempSteps = 0
            var tempStepsFromWatch = 0
            var tempDate: Date?
            for sample in list{
                
                let quantity = (sample as! HKQuantitySample).quantity
                let startDate = (sample as! HKQuantitySample).startDate
                let endDate = (sample as! HKQuantitySample).endDate
                let step = quantity.doubleValue(for: HKUnit.count())
                
                let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                let endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
                if (components.year! == tempYear && components.month! == tempMonth && components.day! == tempDay) ||
                    (endComponents.year! == tempYear && endComponents.month! == tempMonth && endComponents.day! == tempDay){
                    if let deviceName = (sample as! HKQuantitySample).device?.name{
                        if deviceName == "Apple Watch"{
                            if components.year! == endComponents.year! && components.month! == endComponents.month! && components.day! == endComponents.day!{
                                tempStepsFromWatch += Int(step)
                            }else{
                                tempStepsFromWatch += Int(step / 2)
                            }
                        }else if deviceName == "iPhone" {
                            if components.year! == endComponents.year! && components.month! == endComponents.month! && components.day! == endComponents.day!{
                                tempSteps += Int(step)
                            }else{
                                tempSteps += Int(step / 2)
                            }
                        }
                    }
                }else{
                    if let d = tempDate{
                        let maxStep = max(tempStepsFromWatch, tempSteps)
                        resultList.append((d, maxStep, 0))
                    }
                    tempYear = components.year!
                    tempMonth = components.month!
                    tempDay = components.day!
                    tempSteps = 0
                    tempStepsFromWatch = 0
                    if let deviceName = (sample as! HKQuantitySample).device?.name {
                        if deviceName == "Apple Watch"{
                            tempStepsFromWatch += Int(step)
                        }else if deviceName == "iPhone" {
                            tempSteps += Int(step)
                        }
                    }
                    tempDate = startDate
                }
            }
            if let d = tempDate{
                let maxStep = max(tempStepsFromWatch, tempSteps)
                resultList.append((d, maxStep, 0))
            }
            
            //补0
            var tempList = [(Date, Int, Int)]()
            for i in 0..<lastdays {
                var needCreate = true
                
                let realDate = Date().offset(with: -i).GMT()
                let year = calendar.component(.year, from: realDate)
                let month = calendar.component(.month, from: realDate)
                let day = calendar.component(.day, from: realDate)
                for result in resultList {
                    let resultDate = result.0
                    let resultYear = calendar.component(.year, from: resultDate)
                    let resultMonth = calendar.component(.month, from: resultDate)
                    let resultDay = calendar.component(.day, from: resultDate)
                    if resultYear == year && resultMonth == month && resultDay == day {
                        needCreate = false
                        break
                    }
                }
                
                if needCreate {
                    //补
                    tempList.append((realDate, 0, 0))
                }
            }
            for t in tempList{
                resultList.append(t)
            }
            
            //获取距离
            self.getDistanceMList(byLastdays: lastdays, closure: { (distanceMList) in
//                guard resultList.count == distanceMList.count else{
//                    DispatchQueue.main.async {
//                        closure(.failure, [])
//                    }
//                    return
//                }
                
                for (index, element) in distanceMList.enumerated(){
                    if index < resultList.count {
                        resultList[index].2 = element.1
                    }
                }
                
                DispatchQueue.main.async {
                    closure(.success, resultList)
                }
            })
        }
        
        healthStore?.execute(query)
    }
    
    ///获取多日距离
    func getDistanceMList(byLastdays lastdays: Int, closure: @escaping (_ dayDistanceMList: [(Date, Int)])->()){
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else{
            closure([])
            return
        }
        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let predicate = predicateForSamples(byDays: lastdays)
        let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [timeSortDescriptor]) { (query, results, error) in
            guard error == nil else{
                closure([])
                return
            }
            
            guard let list = results else{
                closure([])
                return
            }
            
            var resultList = [(Date, Int)]()

            let calendar = Calendar.current
            var tempYear = 0
            var tempMonth = 0
            var tempDay = 0
            var tempDistanceMs = 0
            var tempDistanceMsFromWatch = 0
            var tempDate: Date?
            for sample in list{
                guard let deviceName = (sample as! HKQuantitySample).device?.name, deviceName != "Apple Watch" else{
                    continue
                }

                let quantity = (sample as! HKQuantitySample).quantity
                let startDate = (sample as! HKQuantitySample).startDate
                let endDate = (sample as! HKQuantitySample).endDate
                let meter = quantity.doubleValue(for: HKUnit.meter())
                
                let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                let endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
                if components.year! == tempYear && components.month! == tempMonth && components.day! == tempDay ||
                (endComponents.year! == tempYear && endComponents.month! == tempMonth && endComponents.day! == tempDay){
                    if let deviceName = (sample as! HKQuantitySample).device?.name {
                        if deviceName == "Apple Watch"{
                            if components.year! == endComponents.year! && components.month! == endComponents.month! && components.day! == endComponents.day! {
                                tempDistanceMsFromWatch += Int(meter)
                            }else {
                                tempDistanceMsFromWatch += Int(meter / 2)
                            }
                        }else if deviceName == "iPhone" {
                            if components.year! == endComponents.year! && components.month! == endComponents.month! && components.day! == endComponents.day! {
                                tempDistanceMs += Int(meter)
                            }else {
                                tempDistanceMs += Int(meter / 2)
                            }
                        }
                    }
                }else{
                    if let d = tempDate{
                        let maxDistanceMs = max(tempDistanceMsFromWatch, tempDistanceMs)
                        resultList.append((d, maxDistanceMs))
                    }
                    tempYear = components.year!
                    tempMonth = components.month!
                    tempDay = components.day!
                    tempDistanceMs = 0
                    tempDistanceMsFromWatch = 0
                    if let deviceName = (sample as! HKQuantitySample).device?.name {
                        if deviceName == "Apple Watch"{
                            tempDistanceMsFromWatch += Int(meter)
                        }else if deviceName == "iPhone" {
                            tempDistanceMs += Int(meter)
                        }
                    }
                    tempDate = startDate
                }
            }
            if let d = tempDate{
                let maxDistanceMs = max(tempDistanceMsFromWatch, tempDistanceMs)
                resultList.append((d, maxDistanceMs / 2))
            }
            
            closure(resultList)
        }
        
        healthStore?.execute(query)
    }
    
    //MARK:- 获取今天的查找
    private func predicateForSamplesToday() -> NSPredicate?{
        return predicateForSamples(byDays: 1)
    }
    
    //MARK:- 获取过去天数的查找
    private func predicateForSamples(byDays day: Int) -> NSPredicate?{
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date(timeIntervalSinceNow: TimeInterval(-day + 1) * 60 * 60 * 24))
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let startDate = calendar.date(from: components) else{
            return nil
        }
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: Date(timeIntervalSinceNow: TimeInterval(0) * 60 * 60 * 24))
        endComponents.hour = 23
        endComponents.minute = 59
        endComponents.second = 59
        
        guard let endDate = calendar.date(from: endComponents) else{
            return nil
        }
//        guard let endDate = calendar.date(byAdding: .day, value: day, to: startDate) else{
//            return nil
//        }
        
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
    }
}
