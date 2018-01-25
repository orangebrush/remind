//
//  DH+User.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
//MARK:- 用户相关操作
extension DataHandler{
    
    func insertMember() -> Member? {

        let idfa = MemberManager.share().idfa
//        if idfa == "00000000-0000-0000-0000-000000000000"{
//            return nil
//        }
        
        let member = NSEntityDescription.insertNewObject(forEntityName: "Member", into: context) as? Member
        member?.idfa = idfa
        
        member?.custom = NSEntityDescription.insertNewObject(forEntityName: "Custom", into: context) as? Custom
        
        guard commit() else {
            return nil
        }
        return member
    }
    
    //MARK:- 获取用户表*如果不存在则插入
    func getMember() -> Member? {

        let request: NSFetchRequest<Member> = Member.fetchRequest()
//        let predicate = NSPredicate(format: "idfa = \"\(idfa)\"")
//        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request)
            if resultList.isEmpty {
                return insertMember()
            }else{
                //判断idfa修改的情况
                let result = resultList.first
                if let dbIdfa = result?.idfa {
                    let idfa = MemberManager.share().idfa
                    if idfa != dbIdfa{
                        let allEvents = getAllEvents()
                        for event in allEvents{
                            result?.removeFromEventList(event)
                        }
                        let allEventClients = getAllEventClients()
                        for eventClient in allEventClients{
                            result?.removeFromEventClientList(eventClient)
                        }
                        commit()
                    }
                }
                return result
            }
        }catch let error{
            debugPrint("<Core Data> fetch error: \(error)")
            return nil
        }
    }
}
