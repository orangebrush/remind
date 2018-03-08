//
//  DM+Notice.swift
//  RemindData
//
//  Created by gg on 08/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation

extension Notice {
    ///用于返回notice头像
    public func iconShot() -> UIImage? {
        if let imageData = iconImageData {
            return UIImage(data: imageData)
        }else if let iconStr = icon {
            let list = iconStr.components(separatedBy: "_")
            if list.count == 2 {
                let iconType = list[0]
                if iconType == "9"{
                    if let image = UIImage(named: "event_" + "\(type)") {
                        return image
                    }
                }
                if let image = UIImage(named: "eventIcon_" + iconStr) {
                    return image
                }
            }
            return UIImage(named: "event_" + "\(type)")
        }
        return nil
    }
}

extension DataManager{
    
    func getNoticeListFromClient(){
        
    }
    
    ///获取消息历史列表(每次进入APP或接收到重要事件提醒调用)
    public func getNoticeList(withPageSize pageSize: Int = 20, withId id: Int = 0, withGetNewNerLog isNew: Bool, closure: @escaping (_ codeResult: CodeResult, _ message: String,_ hasOther: Bool, _ noticeList: [Notice])->()){
        //获取最新的提醒id
        //let noticeId = DataHandler.share().getLastNoticeId()
        let dic = [
            "id": "\(id)",
            //"page": "\(page)",
            "pageSize": "\(pageSize)"
        ]
        
        //判断网络是否可用，否则获取本地数据
        guard isNetworkEnable() else {
            if isNew {
                //closure(.failure, "网络连接错误", false, [])
                let results = DataHandler.share().getNotices(byConditionFormat: "id!=0")
                closure(.success, "获取本地历史提醒成功", false, results)
            }else {
                let results = DataHandler.share().getNotices(byConditionFormat: "id<\(id)")
                closure(.success, "获取本地历史提醒成功", false, results)
            }
            return
        }
        
        Session.session(withAction: isNew ? Actions.getNewestNotices : Actions.getAllNotices, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard codeResult == .success else{
                    closure(.failure, message, false, [])
                    return
                }
                
                guard let dataDic = data as? [String: Any] else{
                    closure(.failure, "wrong json", false, [])
                    return
                }
                
                var hasOther = false
                if let has = dataDic["has"] as? Int{
                    hasOther = has == 1
                }
                
                guard let recordsData = dataDic["records"] as? [[String: Any]] else{
                    return
                }
                
                //解析并保存数据到本地数据库
                let dataHandler = DataHandler.share()
                
                
                var noticeList = [Notice]()
                for recordData in recordsData {
                    guard let id = recordData["id"] as? Int else{                       //id
                        continue
                    }
                    guard let notice = dataHandler.getNotice(byNoticeId: id) else{
                        continue
                    }
                    if let eventId = recordData["eventId"] as? Int{                     //事件id
                        notice.eventId = Int32(eventId)
                    }
                    if let type = recordData["type"] as? Int{                           //事件类型
                        notice.type = Int32(type)
                    }
                    notice.time = recordData["time"] as? String                         //推送日期
                    notice.text1 = recordData["text1"] as? String                       //提醒标题
                    notice.text2 = recordData["text2"] as? String                       //事件提醒日期
                    notice.text3 = recordData["text3"] as? String                       //事件日期
                    notice.text4 = recordData["text4"] as? String                       //正式提醒文本
                    notice.text5 = recordData["text5"] as? String                       //下次提醒文本
                    if let count = recordData["count"] as? Int32{                       //正式提醒次数
                        notice.count = count
                    }
                    notice.notificationId = recordData["notificationId"] as? Int32 ?? 0
                    notice.typeName = recordData["typeName"] as? String                 //类型名称
                    if let sendCount = recordData["sendCount"] as? Int32{               //正式提醒 已提醒次数
                        notice.sendCount = sendCount
                    }
                    if let isBeginningInt = recordData["isBeginning"] as? Int{       //是否预提醒
                        notice.isBeginning = isBeginningInt == 1
                    }
                    if let nextTimeInterval = recordData["nextTime"] as? TimeInterval{  //下次提醒时间
                        notice.nextTime = Date(timeIntervalSince1970: nextTimeInterval/1000)
                    }
                    if let eventTimeInterval = recordData["eventTime"] as? TimeInterval{//事件发生时间
                        notice.eventTime = Date(timeIntervalSince1970: eventTimeInterval/1000)
                    }
                    if let isOperatedInt = recordData["status"] as? Int32{              //0:不再提醒可以操作,1:不再提醒不可以操作
                        notice.isOperated = isOperatedInt == 0
                    }
                    if let icon = recordData["icon"] as? String {
                        notice.icon = icon
                    }
                    if let iconBase64 = recordData["iconBase64"] as? String {
                        if let url = URL(string: iconBase64) {
                            notice.iconImageData = try? Data.init(contentsOf: url)
                        }
                    }else {
                        notice.iconImageData = nil
                    }
                    if let extra = (recordData["extra"] as? [String:Any]){
                        if let lunarYear = extra["lunarYear"] as? Int32{
                            notice.lunarYear = lunarYear
                        }
                        if let ignoreYear = extra["ignoreYear"] as? Int{
                            notice.ignoreYear = ignoreYear == 1
                        }
                    }
                    noticeList.append(notice)
                }
                
                //提交修改
                dataHandler.commit()
                
                //获取本地已存储数据并返回
                var format = ""
                if isNew {
                    var results = noticeList
                    if results.isEmpty {
                        format = "id!=0"
                        results += DataHandler.share().getNotices(byConditionFormat: format, withFetchLimit: pageSize - results.count)
                    }else if results.count < pageSize {
                        
                    }
                    closure(.success, message, hasOther, results)
                }else {
                    format = "id<\(id)"
                    let localNotices = DataHandler.share().getNotices(byConditionFormat: format, withFetchLimit: pageSize)
                    closure(.success, message, hasOther, localNotices)
                }
            }
        }
    }
    
    //MARK:- 获取未读消息个数
    public func getUnreadNoticeCount(withLastId localLastId: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ count: Int, _ lastId: Int)->()){
        let dic = ["id": localLastId]
        Session.session(withAction: Actions.getNoticesCount, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard codeResult == .success else{
                    closure(.failure, message, 0, 0)
                    return
                }
                
                guard let dataDic = data as? [String: Any] else {
                    closure(.failure, "json data error", 0, 0)
                    return
                }
                
                guard let count = dataDic["count"] as? Int, let lastId = dataDic["maxid"] as? Int else {
                    closure(.failure, "count not existed", 0, 0)
                    return
                }
                
                closure(.success, message, count, lastId)
            }
        }
    }
    
    //MARK:- 不再提醒
    public func cancelNotice(withNoticeId noticeId: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        let dic = ["id": "\(noticeId)"]
        Session.session(withAction: Actions.cancelNotice, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
    
    //MARK:- 删除提醒
    public func deleteNotice(withNoticeId noticeId: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        guard isNetworkEnable() else {
            closure(.failure, "连接网络失败")
            return
        }
        
        let dic = ["id": "\(noticeId)"]
        Session.session(withAction: Actions.deleteNotice, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
                if codeResult == .success {
                    DataHandler.share().deleteNotice(withNoticeId: noticeId)
                }
            }
        }
    }
    
    //MARK:- 删除所有提醒
    public func deleteAllNotices(closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        guard isNetworkEnable() else {
            closure(.failure, "连接网络失败")
            return
        }
        
        Session.session(withAction: Actions.deleteAllNotices, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
                if codeResult == .success {
                    for notice in DataHandler.share().getAllNotices(){
                        DataHandler.share().deleteNotice(withNoticeId: Int(notice.id))
                    }
                }
            }
        }
    }
}
