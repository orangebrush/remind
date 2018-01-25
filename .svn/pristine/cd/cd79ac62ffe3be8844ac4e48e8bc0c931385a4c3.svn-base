//
//  DM+EventAndEventClientType.swift
//  RemindData
//
//  Created by gg on 11/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation

//获取方式
public enum ListType: Int{
    case all = 0, onlyEvents, onlyEventClients
}

extension DataManager{
    //MARK:- 获取所有重要事件与每日提醒类型
    public func getAllEventTypeListAndEventClientTypeList(withListType listType: ListType, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ eventTipList: [Tip], _ eventExtraTipList: [Tip], _ eventClientTipList: [Tip])->()){
        let dataHandler = DataHandler.share()
        closure(.success, "成功", dataHandler.getTips(withIsClient: false), dataHandler.getTips(withIsClient: false, withIsExtra: true), dataHandler.getTips(withIsClient: true))
        
        let dic = ["type": "\(listType.rawValue)"]
        Session.session(withAction: Actions.getAddList, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard codeResult == .success else{
                    //closure(.success, message, [], dataHandler.getTips(withIsClient: true))
                    return
                }
                
                guard let dataDic = data as? [String: [[String: Any]]] else{
                    //closure(.failure, "error json data", [], [])
                    return
                }
                
                //删除所有tip
                //dataHandler.deleteAllTips()
                
                //重要事件
                if let eventsData = dataDic["eventType"]{
                    for eventData in eventsData{
                        guard let name = eventData["name"] as? String, let sort = eventData["sort"] as? Int, let type = eventData["type"] as? Int else{
                            continue
                        }
                        
                        let tip = dataHandler.getTip(byTipType: type, withTipName: name, withIsClient: false, withSort: sort)
                        tip?.name = name
                    }
                }
                
                //生日、纪念日
                if let eventExtrasData = dataDic["eventExtraType"] {
                    for eventExtraData in eventExtrasData{
                        guard let name = eventExtraData["name"] as? String, let sort = eventExtraData["sort"] as? Int, let type = eventExtraData["type"] as? Int else{
                            continue
                        }
                        
                        let tip = dataHandler.getTip(byTipType: type, withTipName: name, withIsClient: false, withSort: sort)
                        tip?.name = name
                        tip?.isExtra = true
                    }
                }
                
                //每日提醒
                if let eventClientsData = dataDic["eventClientType"]{
                    for eventClientData in eventClientsData{
                        guard let name = eventClientData["name"] as? String, let sort = eventClientData["sort"] as? Int, let type = eventClientData["type"] as? Int else{
                            continue
                        }

                        let tip = dataHandler.getTip(byTipType: type, withTipName: name, withIsClient: true, withSort: sort)
                        tip?.name = name
                    }
                }
                
                dataHandler.commit()
                
                closure(.success, message, dataHandler.getTips(withIsClient: false), dataHandler.getTips(withIsClient: false, withIsExtra: true), dataHandler.getTips(withIsClient: true))
            }
        }
    }
}
