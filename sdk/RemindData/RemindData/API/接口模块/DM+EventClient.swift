//
//  DM+EventClient.swift
//  RemindData
//
//  Created by gg on 08/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation

///每日提醒-提醒类型：1整点报时、2喝水、3吃药、4活动一下、5闭目养神、6休息一下、7跟TA聊天、8自定义
public enum EventClientType: Int{
    case pointTime = 1, drink, medicine, active, rest, chat, custom
}

///每日提醒声音名称
public enum RingId: String{
    case boy = "boy", girl = "girl"
}

///每日提醒状态
public enum EventClientStatus: Int{
    case normal = 0, pause, delete
}

///Times单个提醒时间
public typealias TimesTuple = (hour: Int, minute: Int)
///Times所有提醒时间
public class Times: NSObject{
    public var list = [TimesTuple]()
    
    ///返回上传格式或用于显示(格式为 08:00，09：00，11:00)
    public func encoderTimes(forServer: Bool = false) -> String{
        var result = ""
        let sortedList = list.sorted{($0.hour * 100 + $0.minute)<($1.hour * 100 + $1.minute)}
        //获取整点报时
        let tempList = sortedList.filter{$0.minute == 0}
        if tempList.count == sortedList.count && !forServer{      //所有数据为整点的情况
            var index = 0
            while index < sortedList.count {
                if index != 0{
                    result += ", "
                }
                let hour = sortedList[index].hour
                let minute = sortedList[index].minute
                let minuteStr = minute < 10 ? "0\(minute)" : "\(minute)"
                var nextIndex = index + 1
                var nextHour = hour + 1
                var addIndex = 0
                while nextIndex < sortedList.count && nextHour == sortedList[nextIndex].hour {
                    nextIndex += 1
                    nextHour += 1
                    addIndex += 1
                }
                if addIndex > 1{
                    index += addIndex
                    let endMinute = sortedList[nextIndex - 1].minute
                    let endMinuteStr = endMinute < 10 ? "0\(endMinute)" : "\(endMinute)"
                    result += "\(hour):" + minuteStr + "~\(nextHour-1):" + endMinuteStr
                }else{
                    result += "\(hour):" + minuteStr
                }
                index += 1
            }
        }else{                                      //正常情况
            for (index, tuple) in sortedList.enumerated(){
                if index != 0{
                    result += ", "
                }
                var hour = tuple.hour
                if hour > 23{
                    hour = 23
                }else if hour < 0{
                    hour = 0
                }
                let hourStr = tuple.hour < 10 && forServer ? "0\(tuple.hour)" : "\(tuple.hour)"
                let minuteStr = tuple.minute < 10 ? "0\(tuple.minute)" : "\(tuple.minute)"
                result += hourStr
                result += ":"
                result += minuteStr
            }
        }
        return result
    }
}

///每日提醒数据模型
class EventClientParam: NSObject{
    public var name = ""
    public var ringId = RingId.boy
    public var type = EventClientType.custom
    public var times = Times()
    public var status = EventClientStatus.normal
}

extension DataManager{
    
    //MARK:- 获取所有本地事件
    public func getAllEventClientList(withPage page: Int = 1, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ eventClientModelList: [EventClient])->()){
        let dict = ["page": "\(page)"]
        Session.session(withAction: Actions.getAllEventClients, withRequestMethod: .post, withParam: dict) { (codeResult, message, data) in
            let dataHandler = DataHandler.share()
            guard codeResult == .success else{
                dataHandler.executeAllEventClients(closure: { (allEventClients) in
                    closure(.failure, message, allEventClients)
                })
                return
            }
            
            let localEventClients = dataHandler.getAllEventClients()
            guard let dataDic = data as? [String: [[String: Any]]] else{
                DispatchQueue.main.async {
                    closure(.failure, "json error", localEventClients)
                }
                return
            }
            
            guard let recordsData = dataDic["records"] else{
                DispatchQueue.main.async {
                    closure(.success, "无数据", localEventClients)
                }
                return
            }
            
            for recordData in recordsData{
                self.getEventClient(fromJsonData: recordData)
            }
            
            dataHandler.commit()
            
            dataHandler.executeAllEventClients(closure: { (eventClients) in
                closure(.success, message, eventClients)
            })
            
            DispatchQueue.main.async {
                
                //添加每日提醒本地推送(主线程中调)
//                for eventClient in localEventClients{
//                    NotifManager.share().addLocalNotification(withEventClient: eventClient)
//                }
            }
        }
    }
    
    //MARK:- 更新每日提醒
    public func updateEventClient(withEventClient eventClient: EventClient, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ eventClientId: Int)->()){
        let dic = [
            "id": "\(eventClient.id)",
            "name": eventClient.name ?? "",
            "times": self.getTimes(fromEventClientTimes: eventClient.timesList)?.encoderTimes(forServer: true) ?? "",
            "ringId": eventClient.ringId ?? RingId.boy.rawValue,
            "type": "\(eventClient.type)",
            "status": "\(eventClient.status)",
            "createDate": "2022"
        ]
        Session.session(withAction: Actions.addEventClient, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                let id = (data as? [String: Int])?["id"] ?? 0
                
                //如果添加成功则修改数据库同步字段
                if codeResult == .success {
                    let dataHandler = DataHandler.share()
                    if let ec = dataHandler.getEventClient(byEventClientType: Int(eventClient.type), byEventClientId: Int(eventClient.id)){
                        ec.isSynced = true
                        ec.status = 0
                        if dataHandler.commit(){
//                            NotifManager.share().deleteNotification(withEventClient: eventClient)
//                            NotifManager.share().addLocalNotification(withEventClient: eventClient)
                        }
                    }
                }
                closure(codeResult, message, id)
            }
        }
    }
    
    //MARK:- 添加每日提醒
    public func addEventClient(withEventClientParam eventClient: EventClient, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ eventClientId: Int)->()){
        
        let dic = [
            "id": "\(eventClient.id)",
            "name": eventClient.name ?? "",
            "times": self.getTimes(fromEventClientTimes: eventClient.timesList)?.encoderTimes(forServer: true) ?? "",
            "ringId": eventClient.ringId ?? "",
            "type": "\(eventClient.type)",
            "status": "\(eventClient.status)",
            "createDate": "2022"
        ]
        let dataHandler = DataHandler.share()
        if let ec = dataHandler.getEventClient(byEventClientType: Int(eventClient.type), byEventClientId: Int(eventClient.id)){
            ec.isSynced = true
            ec.status = 0
            //先添加到本地
            if dataHandler.commit(){
                closure(.success, "添加成功", Int(eventClient.id))
                //后同步到服务器
                Session.session(withAction: Actions.addEventClient, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
                    DispatchQueue.main.async {
                        if codeResult == .success {
                        }
                        
                        //let id = (data as? [String: Int])?["id"] ?? 0
                    }
                }
            }else{
                closure(.failure, "添加失败", 0)
            }
        }
    }
    
    //MARK:- 开始提醒
    public func startEventClient(withEventClientType eventClientType: Int, withEventClientId eventClientId: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ eventClientId: Int)->()){
        let dic = [
            "id": "\(eventClientId)",
            "type": "\(eventClientType)"
        ]
        Session.session(withAction: Actions.startEventClient, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                let id = (data as? [String: Int])?["id"] ?? 0
                if codeResult == .success {
                    if let eventClient = DataHandler.share().getEventClient(byEventClientType: eventClientType, byEventClientId: eventClientId){
                        //设置每日提醒为开始
                        eventClient.status = 0
                        DataHandler.share().commit()
                    }
                }
                closure(codeResult, message, id)
            }
        }
    }
    
    //MARK:- 暂停提醒
    public func pauseEventClient(withEventClientType eventClientType: Int, withEventClientId eventClientId: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ eventClientId: Int)->()){
        let dic = [
            "id": "\(eventClientId)",
            "type": "\(eventClientType)"
        ]
        Session.session(withAction: Actions.pauseEventClient, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                let id = (data as? [String: Int])?["id"] ?? 0
                if codeResult == .success {
                    if let eventClient = DataHandler.share().getEventClient(byEventClientType: eventClientType, byEventClientId: eventClientId){
                        //设置每日提醒为暂停
                        eventClient.status = 1
                        DataHandler.share().commit()
                        
                        
                        //删除提醒
                        NotifManager.share().deleteNotification(withEventClientType: eventClientType, withEventClientId: eventClientId)
                    }
                }
                closure(codeResult, message, id)
            }
        }
    }
    
    //MARK:- 删除提醒
    public func deleteEventClient(withEventClientType eventClientType: Int, withEventClientId eventClientId: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ eventClientId: Int)->()){
        let dataHandler = DataHandler.share()
        
        //先删除本地
        if let eventClient = dataHandler.getEventClient(byEventClientType: eventClientType, byEventClientId: eventClientId){
            //设置每日提醒为删除
            eventClient.status = 2
            eventClient.isSynced = false
            
            dataHandler.deleteAllEventClientTimes(withEventClientType: eventClientType, withEventClientId: eventClientId)
//            if let oldTimes = getTimes(fromEventClientTimes: eventClient.timesList){
//                for _ in oldTimes.list{
//                    dataHandler.deleteEventClientTimes(withEventClientId: eventClientId)
//                }
//            }
            
            //删除提醒
            NotifManager.share().deleteNotification(withEventClientType: eventClientType, withEventClientId: eventClientId)
         
            //本地删除成功后调用网络删除
            if dataHandler.commit(){
                let dic = [
                    "id": "\(eventClientId)",
                    "type": "\(eventClientType)"
                ]
                Session.session(withAction: Actions.deleteEventClient, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
                    DispatchQueue.main.async {
                        let id = (data as? [String: Int])?["id"] ?? 0
                        if codeResult == .success {
                        }
                        
                        eventClient.isSynced = true
                        dataHandler.commit()
                        closure(codeResult, message, id)
                    }
                }
            }
        }
    }
    
    
    //******************************************************************************************************************************
    func getEventClientModel(fromJsonData jsonData: Any?) -> EventClientModel?{
        guard let recordData = jsonData as? [String: Any] else{
            return nil
        }
        guard let id = recordData["id"] as? Int, let type = recordData["type"] as? Int else{               //提醒id type
            return nil
        }
        
        var eventClientModel = EventClientModel()
        eventClientModel.id = id
        eventClientModel.type = type
        eventClientModel.name = recordData["name"] as? String ?? ""
        if let timesStr = recordData["times"] as? String{           //提醒时间
            let times = self.decoderTimes(withTimesStr: timesStr)
            eventClientModel.times = times
        }
        eventClientModel.ringId = recordData["ringId"] as? String ?? "girl"       //提醒铃声
        eventClientModel.afterInterval = recordData["afterInterval"] as? Int ?? 0
        eventClientModel.createDate = recordData["createDate"] as? String ?? ""
        eventClientModel.status = recordData["status"] as? Int ?? 0
        eventClientModel.timeText = recordData["timeText"] as? String ?? ""
        eventClientModel.nextNextTime = recordData["nextNextTime"] as? String ?? ""
        return eventClientModel
    }
    
    @discardableResult
    func getEventClient(fromJsonData jsonData: Any?) -> EventClient?{
        guard let recordData = jsonData as? [String: Any] else{
            return nil
        }
        guard let id = recordData["id"] as? Int, let type = recordData["type"] as? Int else{               //提醒id type
            return nil
        }
        
        let dataHandler = DataHandler.share()
        
        //从数据库获取每日提醒
        guard let eventClient = dataHandler.getEventClient(byEventClientType: type, byEventClientId: id) else{
            return nil
        }
        
        
        //重置最后lastid
        PlistManager.share().setLastId(withNewLastId: id)
        
        //需范围updateDate作对比
        
        eventClient.name = recordData["name"] as? String            //提醒名称
        eventClient.typeName = recordData["typeName"] as? String    //类型名称
        if let timesStr = recordData["times"] as? String{           //提醒时间

            //判断是否需要更新times
            if let oldTimes = getTimes(fromEventClientTimes: eventClient.timesList){
                if oldTimes.encoderTimes(forServer: true) != timesStr{
                    
                    for _ in oldTimes.list{
                        dataHandler.deleteEventClientTimes(withEventClientId: id)
                    }
                    
                    let times = self.decoderTimes(withTimesStr: timesStr)
                    for time in times.list{
                        if let eventClientTimes = dataHandler.insertEventClientTimes(withEventClientType: type, withEventClientId: id){
                            eventClientTimes.hour = Int32(time.hour)
                            eventClientTimes.minute = Int32(time.minute)
                        }
                    }
                    
                    //更新本地推送
                    DispatchQueue.main.async {                        
                        NotifManager.share().addLocalNotification(withEventClient: eventClient)
                    }
                }
            }
        }
        eventClient.ringId = recordData["ringId"] as? String        //提醒铃声
//        if let status = recordData["status"] as? Int32{             //状态(状态值已本地为准，不做参考)
//            eventClient.status = status
//        }
        eventClient.afterInterval = recordData["afterInterval"] as? Int32 ?? 0
        eventClient.userTime = recordData["userTime"] as? String
        dataHandler.commit()
        return eventClient
    }
    
    ///转换times
    public func getTimes(fromEventClientTimes eventClientTimes: NSSet?) -> Times?{
        guard let evtClnTimes = eventClientTimes else {
            return Times()
        }
        
        let times = Times()
        for element in evtClnTimes{
            if let ecTimes = element as? EventClientTimes{
                let timesTuple = (Int(ecTimes.hour), Int(ecTimes.minute))
                times.list.append(timesTuple)
                times.list.sort(by: { (a, b) -> Bool in
                    if a.0<b.0{
                        return true
                    }else if a.0>b.0{
                        return false
                    }else{
                        if a.1<=b.1{
                            return true
                        }else {
                            return false
                        }
                    }
                 
                })
            }
        }
        return times
    }
    
    
    //MARK:- 映射times
    func decoderTimes(withTimesStr timeStr: String) -> Times{
        let strList = timeStr.components(separatedBy: ", ")
        let times = Times()
        for str in strList{
            let subList = str.components(separatedBy: ":")
            guard subList.count == 2 else{
                continue
            }
            let hour = Int(subList[0]) ?? 0
            let half = Int(subList[1]) ?? 0
            let tuple = (hour, half)
            times.list.append(tuple)
        }
        return times
    }
}
