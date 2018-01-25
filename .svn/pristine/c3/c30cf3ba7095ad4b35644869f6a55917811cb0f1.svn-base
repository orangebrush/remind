//
//  DM+Info.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation

public struct InfoModel{
    ///无用
    public var weixinId = ""
    public var isWeixinBinding = false
    public var emailAddr = ""
    public var isEmailBinding = false
    public var birthday: Date?
    ///星座
    public var constellation = ""
    ///剩余提醒消息
    public var leftSmsCount: Int = 0
    public var idfa: String?
    public var uuid: String?
    ///微信
    public var nickName: String = ""
    ///生肖
    public var zodiac = ""
    ///微信头像
    public var wxAvatar = ""
}


extension DataManager{
    
    //MARK:- 获取个人信息
    public func getInfo(closure: @escaping (_ codeResult: CodeResult, _ message: String, _ infoModel: InfoModel)->()){
        Session.session(withAction: Actions.getInfo, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard codeResult == .success else{
                    closure(.failure, message, InfoModel())
                    return
                }
                
                var infoModel = InfoModel()
                if let dataDic = data as? [String: Any]{

                    infoModel.weixinId = dataDic["wxNickName"] as? String ?? ""
                    infoModel.emailAddr = dataDic["emailAddr"] as? String ?? ""
                    if let bindWeixin = dataDic["bindWeixin"] as? Int{
                        infoModel.isWeixinBinding = bindWeixin == 1
                    }
                    if let bindEmail = dataDic["bindEmail"] as? Int{
                        infoModel.isEmailBinding = bindEmail == 1
                    }
                    if let birthdayInterval = dataDic["birthday"] as? Int, birthdayInterval > 0{
                        infoModel.birthday = Date(timeIntervalSince1970: TimeInterval(birthdayInterval) / 1000)
                    }
                    infoModel.zodiac = dataDic["zodiac"] as? String ?? ""
                    infoModel.constellation = dataDic["constellation"] as? String ?? ""
                    infoModel.nickName = dataDic["wxNickName"] as? String ?? ""
                    infoModel.leftSmsCount = dataDic["leftSmsCount"] as? Int ?? 0
                    infoModel.idfa = dataDic["idfa"] as? String
                    infoModel.uuid = dataDic["uid"] as? String
                    
                    infoModel.wxAvatar = dataDic["wxAvatar"] as? String ?? ""
                }
                closure(.success, message, infoModel)
            }
        }
    }
    
    //MARK:- 更新手机名称
    public func updatePhoneName(withPhoneName phoneName: String, closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        let dic = ["phoneName": phoneName]
        
        Session.session(withAction: Actions.updatePhoneName, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
}
