//
//  DH+EventType.swift
//  RemindData
//
//  Created by gg on 09/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
extension DataHandler{
    /*
    //添加默认事件
    func insertEventEnumType(withEventType eventType: Int, withEventName eventName: String, withClient isClient: Bool) -> EventEnumType?{
        guard let eventEnumType = NSEntityDescription.insertNewObject(forEntityName: "EventEnumType", into: context) as? EventEnumType else{
            return nil
        }
        eventEnumType.type = Int32(eventType)
        eventEnumType.isNew = true
        eventEnumType.name = eventName
        eventEnumType.isClient = isClient
        
        
        //添加关系表... oneToOne
        guard let member = getMember() else{
            return nil
        }
        
        member.addToEventEnumTypeList(eventEnumType)
        
        guard commit() else {
            return nil
        }
        return eventEnumType
    }
    
    //MARK:- 一次性添加所有事件类型（等待api）
    public func addAllEventEnumTypes() -> [EventEnumType]{
        return []
    }
    
    //MARK:- 添加单个事件类型（每次请求后添加）
    public func addEventEnumType(byEventType eventType: Int, withEventName eventName: String, withClient isClient: Bool) -> EventEnumType?{
        let request: NSFetchRequest<EventEnumType> = EventEnumType.fetchRequest()
        let predicate = NSPredicate(format: "type=\(eventType)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                let newEventEnumType = insertEventEnumType(withEventType: eventType, withEventName: eventName, withClient: isClient)
                return newEventEnumType
            }else{
                let result = resultList.first
                result?.isNew = false
                return result
            }
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return nil
        }
    }
    
    //MARK:- 获取所有事件类型
    public func getAllEventEnumTypeList() -> [EventEnumType]{
        let request: NSFetchRequest<EventEnumType> = EventEnumType.fetchRequest()
        let predicate = NSPredicate()
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //MARK:- 删除事件类型(暂时不做删除处理)
    func deleteEventEnumType(withEventType eventType: Int){
        delete(Event.self, byConditionFormat: "type=\(eventType)")
    }
     */
}
