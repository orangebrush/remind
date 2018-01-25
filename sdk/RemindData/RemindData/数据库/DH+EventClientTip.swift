//
//  DH+EventClientTip.swift
//  RemindData
//
//  Created by gg on 11/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
extension DataHandler{
    //插入每日提醒tip
    private func insertTip(withTipType tipType: Int, withTipName tipName: String, withIsClient isClient: Bool, withSort sort: Int) -> Tip?{
        guard let tip = NSEntityDescription.insertNewObject(forEntityName: "Tip", into: context) as? Tip else{
            return nil
        }
        tip.type = Int32(tipType)
        tip.sort = Int32(sort)
        tip.isClient = isClient
        if isClient {
            switch tipType{
            case 0..<9:
                tip.isNew = false
            default:
                tip.isNew = true
            }
        }else{
            switch tipType{
            case 0, 1, 2, 4, 6, 7, 8, 9, 10, 11:
                tip.isNew = false
            default:
                tip.isNew = true
            }
        }
        
        //添加关系表... oneToOne
        guard let member = getMember() else{
            return nil
        }
        
        member.addToTipList(tip)
        guard commit() else {
            return nil
        }
        return tip
    }
    
    ///获取并创建单个事件
    public func getTip(byTipType tipType: Int, withTipName tipName: String, withIsClient isClient: Bool, withSort sort: Int) -> Tip?{
        let request: NSFetchRequest<Tip> = Tip.fetchRequest()
        let predicate = NSPredicate(format: "type=\(tipType) AND isClient=\(isClient)")
        
        request.predicate = predicate

        do{
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                return insertTip(withTipType: tipType, withTipName: tipName, withIsClient: isClient, withSort: sort)
            }else{
                let tip = resultList.first
                //tip?.isNew = false
                return tip
            }
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return nil
        }
    }
    
    ///获取单个事件
    public func getSingleTip(closure: @escaping (Tip?)->()) {
        let request: NSFetchRequest<Tip> = Tip.fetchRequest()
        let predicate = NSPredicate(format: "type=11 AND isClient=\(false)")
        
        request.predicate = predicate
        
        executeSelect(withFetchRequest: request as! NSFetchRequest<NSFetchRequestResult>) { (results) in
            if let tips = results as? [Tip]{
                closure(tips.first)
            }else{
                closure(nil)
            }
        }
    }
    
    //MARK:- 获取tip
    public func getTips(withIsClient isClient: Bool, withIsExtra isExtra: Bool = false) -> [Tip]{
        let request: NSFetchRequest<Tip> = Tip.fetchRequest()
        
        do{
            let resultList = try context.fetch(request)
            let list = resultList.filter{$0.isClient == isClient && $0.isExtra == isExtra}
            return list
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return []
        }
    }
    
    //MARK:- 删除所有tip
    public func deleteAllTips(){
        var list = getTips(withIsClient: true)
        list += getTips(withIsClient: false)
        for tip in list{
            deleteTip(withTipType: Int(tip.type))
        }
    }
    
    //MARK:- 删除tip
    private func deleteTip(withTipType tipType: Int){
        delete(Tip.self, byConditionFormat: "type=\(tipType)")
    }
}
