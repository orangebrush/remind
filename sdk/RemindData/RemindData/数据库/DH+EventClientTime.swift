//
//  DH+EventClientTime.swift
//  RemindData
//
//  Created by gg on 15/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
extension DataHandler{
    //插入beginning
    public func insertEventClientTimes(withEventClientType eventClientType: Int, withEventClientId eventClientId: Int) -> EventClientTimes?{
        guard let times = NSEntityDescription.insertNewObject(forEntityName: "EventClientTimes", into: context) as? EventClientTimes else{
            return nil
        }
        
        guard let eventClient = getEventClient(byEventClientType: eventClientType, byEventClientId: eventClientId) else{
            return nil
        }
        
        eventClient.addToTimesList(times)
        guard commit() else {
            return nil
        }
        return times
    }
    
    ///根据每日提醒移除所有提醒时间
    public func deleteAllEventClientTimes(withEventClientType eventClientType: Int, withEventClientId eventClientId: Int){
        let request: NSFetchRequest<EventClientTimes> = EventClientTimes.fetchRequest()
        
        let predicate = NSPredicate(format: "(eventClient.id=\(eventClientId) AND eventClient.type=\(eventClientType)) OR eventClient==nil")
        request.predicate = predicate
        
        executeSelect(withFetchRequest: request as! NSFetchRequest<NSFetchRequestResult>) { (results) in
            for result in results{
                self.context.delete(result as! NSManagedObject)
                self.commit()
            }
        }
    }
    
    public func deleteEventClientTimes(withEventClientId eventClientId: Int){
        
        delete(EventClientTimes.self, byConditionFormat: "eventClient.id=\(eventClientId)")
    }
    
    ///根据每日提醒移除所有提醒时间
    public func executeDeleteAllEventClientTimes(withEventClientId eventClientId: Int, closure: @escaping ()->()){
        let request: NSFetchRequest<EventClientTimes> = EventClientTimes.fetchRequest()
        
        let predicate = NSPredicate(format: "eventClient.id=\(eventClientId) or eventClient==nil")
        request.predicate = predicate
        
        executeSelect(withFetchRequest: request as! NSFetchRequest<NSFetchRequestResult>) { (results) in
            for result in results{
                self.context.delete(result as! NSManagedObject)
            }
            self.commit()
            closure()
        }
    }
    
    //
//    func getEventClientTimes(withEventClientTimeId timesObjectId: NSManagedObjectID) -> EventClientTimes?{
//        let request: NSFetchRequest<EventClientTimes> = EventClientTimes.fetchRequest()
//        let predicate = NSPredicate(format: "eventClient.objectID=\(timesObjectId)")
//        
//        request.predicate = predicate
//        do{
//            let resultList = try context.fetch(request)
//            return resultList.first ?? nil
//        }catch let error{
//            fatalError("<Core Data Delete>  error: \(error)")
//        }
//    }
    
}
