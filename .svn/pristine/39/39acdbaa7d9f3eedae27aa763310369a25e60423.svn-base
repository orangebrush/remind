//
//  UserManager.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
import AdSupport
private var localIdfa: String?
private var localUuid: String?
public final class MemberManager{
    //MARK:- class init *****************************************************************************************************
    struct singleton{
        static var instance = MemberManager()
    }
    public class func share() -> MemberManager{
        return singleton.instance
    }
    //***************************************************************************************************
    
    //MARK:- 获取本地idfa
    public var idfa: String{
        get{
            if let lIdfa = localIdfa {
                return lIdfa
            }
            let uuidString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            localIdfa = uuidString
            return uuidString
        }
    }
    
    //MARK:- 获取idfv
    public var idfv: String? {
        get{
            return UIDevice.current.identifierForVendor?.uuidString
        }
    }
    
    //MARK:- 获取设备名称
    public var deviceName: String{
        get{
            return UIDevice.current.name
        }
    }
    
    //MARK:- 同步数据到数据库
    public func commit(){
        _ = DataHandler.share().commit()
    }
    
    public var uuid: String? {
        get{
            if let lUUID = localUuid{
                return lUUID
            }
            return member?.uuid
        }
    }
    
    //MARK:- member
    public var member: Member? {
        get{            
            return DataHandler.share().getMember()
        }
    }
}
