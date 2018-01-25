//
//  DH+Frequency.swift
//  RemindData
//
//  Created by gg on 15/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import CoreData
extension DataHandler{
    //插入day
    public func insertFrequencyDay(withEventId eventId: Int) -> FrequencyDay?{
        guard let frequencyDay = NSEntityDescription.insertNewObject(forEntityName: "FrequencyDay", into: context) as? FrequencyDay else{
            return nil
        }
        
        guard let event = getEvent(byEventId: eventId) else{
            return nil
        }
        
        event.frequency?.addToDays(frequencyDay)        
        guard commit() else {
            return nil
        }
        return frequencyDay
    }
    
    //插入month
    public func insertFrequencyMonth(withEventId eventId: Int) -> FrequencyMonth?{
        guard let frequencyMonth = NSEntityDescription.insertNewObject(forEntityName: "FrequencyMonth", into: context) as? FrequencyMonth else{
            return nil
        }
        
        guard let event = getEvent(byEventId: eventId) else{
            return nil
        }
        
        event.frequency?.addToMonths(frequencyMonth)
        guard commit() else {
            return nil
        }
        return frequencyMonth
    }
    
    //插入weekday
    public func insertFrequencyWeekday(withEventId eventId: Int) -> FrequencyWeekday?{
        guard let frequencyWeekday = NSEntityDescription.insertNewObject(forEntityName: "FrequencyWeekday", into: context) as? FrequencyWeekday else{
            return nil
        }
        
        guard let event = getEvent(byEventId: eventId) else{
            return nil
        }
        
        event.frequency?.addToWeekdays(frequencyWeekday)
        guard commit() else {
            return nil
        }
        return frequencyWeekday
    }
}
