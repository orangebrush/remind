//
//  DH+Event.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
extension DataHandler{
    //必须在有网络的情况下才能添加重要事件（意味着先获取得到id，再通过获取插入新事件）
    func insertEvent(withEventId eventId: Int) -> Event?{
        guard let event = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context) as? Event else{
            return nil
        }
        event.id = Int32(eventId)
        event.createDate = Date()
        
        event.beginningNext = NSEntityDescription.insertNewObject(forEntityName: "Beginning", into: context) as? Beginning
        event.frequency = NSEntityDescription.insertNewObject(forEntityName: "Frequency", into: context) as? Frequency
        event.frequency?.weeksTuple = NSEntityDescription.insertNewObject(forEntityName: "FrequencyWeeksTuple", into: context) as? FrequencyWeeksTuple
        
        //添加关系表... oneToOne
        guard let member = getMember() else{
            return nil
        }
        
        member.addToEventList(event)
        guard commit() else {
            return nil
        }
        return event
    }
    
    //MARK:- 获取单个事件
    public func getEvent(byEventId eventId: Int) -> Event?{
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let predicate = NSPredicate(format: "id=\(eventId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                return insertEvent(withEventId: eventId)
            }else{
                return resultList.first
            }
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return nil
        }
    }
    
    //MARK:- 获取所有事件
    public func getAllEvents() -> [Event]{
        let request: NSFetchRequest<Event> = Event.fetchRequest()
//        let predicate = NSPredicate()
//        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //MARK:- 删除事件(暂时不做删除处理)
    func deleteEvent(withEventId eventId: Int){
        delete(Event.self, byConditionFormat: "id=\(eventId)")
    }
    
    //MARK:- 删除所有事件
    public func deleteAllEvent(){
        
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        
        do{
            let resultList = try context.fetch(request)
            for result in resultList{
                context.delete(result)
            }
            
            commit()
        }catch let error{
            fatalError("<Core Data Delete>  error: \(error)")
        }
    }
}
