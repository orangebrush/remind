//
//  DM+Holiday.swift
//  RemindData
//
//  Created by gg on 26/01/2018.
//  Copyright © 2018 ganyi. All rights reserved.
//

import Foundation
public struct HolidaySetting{
    ///是否在日历中显示
    public var isShowInCalendar = false
    ///是否提醒
    public var isRemind = false
    ///预提醒
    public var beginning = BeginningModel()
    ///提示音
    public var ring = "Rhythm"
    ///提醒时间
    public var beginTime = Date()
}


extension DataManager {
    ///获取节假日设置
    public func getHolidaySetting(closure: @escaping (CodeResult, String, HolidaySetting)->()){
        Session.session(withAction: Actions.getHolidaySetting, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            DispatchQueue.main.async {
                var holidaySetting = HolidaySetting()
                guard codeResult == .success else{
                    closure(.failure, message, holidaySetting)
                    return
                }
                
                guard let dataDic = data as? [String: Any] else {
                    closure(.failure, "json data error", holidaySetting)
                    return
                }
                
                holidaySetting.isShowInCalendar = dataDic["showFlag"] as? Bool ?? false
                holidaySetting.isRemind = dataDic["remindFlag"] as? Bool ?? false
                holidaySetting.ring = dataDic["ring"] as? String ?? "Rhythm"
                if let beginTimeStr = dataDic["beginTime"] as? String{
                    holidaySetting.beginTime = Date(withDateStr: beginTimeStr, withFormatStr: "H:m")
                }
                if let beginningStr = dataDic["beginning"] as? String{
                    holidaySetting.beginning.list = self.decoderBeginningList(withBeginningStr: beginningStr)
                }
                
                closure(.success, message, holidaySetting)
            }
        }
    }
    
    ///保存节假日设置
    public func setHolidaySetting(withHolidaySetting holidaySetting: HolidaySetting, closure: @escaping (CodeResult, String)->()){
        let dic: [String: Any] = [
            "showFlag": holidaySetting.isShowInCalendar,
            "remindFlag": holidaySetting.isRemind,
            "beginning": holidaySetting.beginning.encoderList(),
            "ring": holidaySetting.ring,
            "beginTime": holidaySetting.beginTime.formatString(with: "H:mm")
        ]

        Session.session(withAction: Actions.setHolidaySetting, withRequestMethod: .post, withParam: dic) { (codeResult, message, _) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
}
