//
//  DataHandler.swift
//  RemindData
//
//  Created by gg on 04/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

//数据库错误信息
public enum GodError: Error{
    case fetchNoResult
}

public class DataHandler {
    
    //coredata-context
    let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
//    let mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    //日历
    let calendar = Calendar.current
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    //MARK:- 加载编译后数据模型路径 momd
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Frameworks/RemindData.framework/Model", withExtension: "momd")!
        debugPrint("<Core Data> mode url: \(modelURL)")
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    //MARK:- 设置数据库写入路径 并范围数据库协调器
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("remind.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            debugPrint("<Core Data> Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()    
    
    //MARK:- class init *****************************************************************************************************
    struct singleton{
        static var instance = DataHandler()
    }
    
    @discardableResult
    public class func share() -> DataHandler{
        return singleton.instance
    }
    
    //MARK:- init *****************************************************************************************************
    init() {
        config()
    }
    
    private func config(){
        
        context.persistentStoreCoordinator = persistentStoreCoordinator
//        mainContext.persistentStoreCoordinator = persistentStoreCoordinator
        
    }
    
    //MARK:- 修正日期 范围包含年月日日期
    func translate(_ date: Date, withDayOffset offset: Int = 0) -> Date{
        
        let resultDate = Date(timeInterval: TimeInterval(offset) * 60 * 60 * 24, since: date)
        
        let components = calendar.dateComponents([.year, .month, .day], from: resultDate)
        
        return calendar.date(from: components)!
    }
    
    // MARK: - Core Data Saving support
    @discardableResult
    public func commit() -> Bool{
        if context.hasChanges {
            do {
                debugPrint("<Core Data Commit>------------------------commit---------------------- ctx:", context)
                try context.save()
                return true
            } catch let error {
                debugPrint("<Core Data Commit> error context: \(context), error: \(error)")
            }
        }
//        if mainContext.hasChanges{
//            do {
//                debugPrint("<Core Data Commit>----------------------main commit------------------- ctx:", mainContext)
//                try mainContext.save()
//                return true
//            } catch let error {
//                debugPrint("<Core Data Commit> error main context: \(context), error: \(error)")
//            }
//        }
        return false
    }
    
    //MARK:- 丢弃修改
    @discardableResult
    public func reset() -> Bool{
        if context.hasChanges {
            context.reset()            
            return true
        }
        return false
    }
    
    //MARK:- 执行
    func executeSelect(withFetchRequest fetchRequest: NSFetchRequest<NSFetchRequestResult>, closure: @escaping ([NSFetchRequestResult])->()) {
        let async = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            let finalResult = result.finalResult
            DispatchQueue.main.async {      //切换到主线程
                closure(finalResult ?? [])
            }
        }
        context.perform{
            do{
                try self.context.execute(async)
            }catch let error{
                debugPrint("<Core Data> fetch error: \(error)")
            }
        }
    }
    
    //MARK:- 执行
    func executeSelectAndWait(withFetchRequest fetchRequest: NSFetchRequest<NSFetchRequestResult>, closure: @escaping ([NSFetchRequestResult])->()) {
        let async = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            let finalResult = result.finalResult
            DispatchQueue.main.async {      //切换到主线程
                closure(finalResult ?? [])
            }
        }
        context.performAndWait {
            do{
                try self.context.execute(async)
            }catch let error{
                debugPrint("<Core Data> fetch error: \(error)")
            }
        }
    }
    
    //MARK:- *增* insertTable with tableName and initKeyValue
    fileprivate func insert(_ tableClass: NSManagedObject.Type, withInitItems initItems: [String: Any]? = nil) throws {
        
        let tableObject = NSEntityDescription.insertNewObject(forEntityName: "\(tableClass.self)", into: context)
        
        if let items = initItems {
            tableObject.setValuesForKeys(items)
        }
        commit()
    }
    
    //MARK:- *删* deleteTable by condition
    func delete(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String) {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: conditionFormat)
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request) as! [NSManagedObject]
            if let last = resultList.last{
                context.delete(last)
                commit()
            }else{

            }
        }catch let error{
            fatalError("<Core Data Delete> \(tableClass) error: \(error)")
        }
    }
    
    //MARK:- *查* selectTable by condition
    fileprivate func select(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String) throws -> NSManagedObject{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: conditionFormat, "")
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request) as! [NSManagedObject]
            
            if resultList.isEmpty {
                throw GodError.fetchNoResult
            }else{
                return resultList[0]
            }
        }catch let error{
            throw error
        }
    }
    
    //MARK:- *改* updateTable by condition with keyValue
    fileprivate func update(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String, withUpdateItems items: [String: Any]) throws{
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: conditionFormat, "")
        request.predicate = predicate
        
        let resultList = try context.fetch(request) as! [NSManagedObject]
        if resultList.isEmpty {
            throw GodError.fetchNoResult
        }else{
            resultList[0].setValuesForKeys(items)
            guard commit() else{
                return
            }
        }
    }
}

