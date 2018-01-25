//
//  EventManager.swift
//  RemindData
//
//  Created by gg on 06/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
public final class EventManager{
    //MARK:- class init *****************************************************************************************************
    struct singleton{
        static var instance = EventManager()
    }
    public class func share() -> EventManager{
        return singleton.instance
    }
    //***************************************************************************************************
    
    
}
