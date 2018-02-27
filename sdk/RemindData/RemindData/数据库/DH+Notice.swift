//
//  DH+Notice.swift
//  RemindData
//
//  Created by gg on 08/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData

//MARK:- 添加是否可点击操作显示
extension Notice{
    
    //MARK:- 判断不再提醒按钮是否可操作
    public func canOperated() -> Bool{
        guard isOperated else{
            return false
        }
        
        let newerNoticeList = DataHandler.share().getNotices(byNotice: self)
        return newerNoticeList.isEmpty
    }
}

extension DataHandler{
    //MARK:- 插入提醒
    func insertNotice(withNoticeId noticeId: Int) -> Notice?{
        guard let notice = NSEntityDescription.insertNewObject(forEntityName: "Notice", into: context) as? Notice else{
            return nil
        }
        notice.id = Int32(noticeId)
        
        //添加关系表... oneToOne
        guard let member = getMember() else{
            return nil
        }
        
        member.addToNoticeList(notice)
        
        guard commit() else {
            return nil
        }
        return notice
    }
    
    //MARK:- 获取近期的同eventId的notice
    func getNotices(byNotice notice: Notice) -> [Notice]{
        let request: NSFetchRequest<Notice> = Notice.fetchRequest()
        let predicate = NSPredicate(format: "id>\(notice.id) AND eventId=\(notice.eventId)")
        
        request.predicate = predicate
        
        do {
            let resultList = try context.fetch(request)
            return resultList
        } catch let error {
            debugPrint("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //MARK:- 获取最后一个提醒的id(如果为第一次的话id为0)
    public func getLastNoticeId() -> Int{
        let all = getAllNotices()
        let sortAll = all.sorted{$0.id<$1.id}
        
        return Int(sortAll.last?.id ?? 0)
    }
    
    //MARK:- 获取单个提醒
    public func getNotice(byNoticeId noticeId: Int) -> Notice?{
        let request: NSFetchRequest<Notice> = Notice.fetchRequest()
        let predicate = NSPredicate(format: "id=\(noticeId)")
        
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                return insertNotice(withNoticeId: noticeId)
            }else{
                return resultList.first
            }
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return nil
        }
    }
    
    //MARK:- 根据条件获取提醒
    public func getNotices(byConditionFormat conditionFormat: String, withFetchLimit fetchLimit: Int = 20) -> [Notice] {
        let request: NSFetchRequest<Notice> = Notice.fetchRequest()
        
        let predicate = NSPredicate(format: conditionFormat)
        request.predicate = predicate
        
        request.fetchLimit = fetchLimit

        let needReversed = conditionFormat == "id!=0"
        let sort = NSSortDescriptor(key: "id", ascending: needReversed ? false : true)
        
        request.sortDescriptors = [sort]
        
        do{
            let resultList = try context.fetch(request)
            return needReversed ? resultList.reversed() : resultList
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    
    //MARK:- 获取所有提醒
    public func getAllNotices() -> [Notice]{
        let request: NSFetchRequest<Notice> = Notice.fetchRequest()
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //MARK:- 删除提醒
    func deleteNotice(withNoticeId noticeId: Int){
        delete(Notice.self, byConditionFormat: "id=\(noticeId)")
    }
}
