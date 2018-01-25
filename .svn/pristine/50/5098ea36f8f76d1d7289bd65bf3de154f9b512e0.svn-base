//
//  DH+Beginning.swift
//  RemindData
//
//  Created by gg on 15/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
extension DataHandler{
    //插入beginning
    public func insertBeginning(withEventId eventId: Int) -> Beginning?{
        guard let beginning = NSEntityDescription.insertNewObject(forEntityName: "Beginning", into: context) as? Beginning else{
            return nil
        }

        //添加关系表... oneToOne
        guard let event = getEvent(byEventId: eventId) else{
            return nil
        }
        
        event.addToBeginningList(beginning)
        guard commit() else {
            return nil
        }
        return beginning
    }
    
    //MARK:- 获取
    public func getBeginning(byEventId eventId: Int) -> [Beginning]{
        guard let beginningList = getEvent(byEventId: eventId)?.beginningList else{
            return []
        }
        var resultList = [Beginning]()
        for element in beginningList{
            if let bgn = element as? Beginning{
                resultList.append(bgn)
            }
        }
        return resultList
    }
}
