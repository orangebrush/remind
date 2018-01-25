//
//  UserManager.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import AdSupport
public final class UserManager{
    //MARK:- class init *****************************************************************************************************
    struct singleton{
        static var instance = DataManager()
    }
    public class func share() -> DataManager{
        return singleton.instance
    }
    
    //MARK:- 获取本地idfa
    public var idfa: String{
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    //MARK:- 获取设备名称
    public var deviceName: String{
        return UIDevice.current.name
    }
}
