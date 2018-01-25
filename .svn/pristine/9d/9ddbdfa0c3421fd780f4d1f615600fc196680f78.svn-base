//
//  DM+Calendar.swift
//  RemindData
//
//  Created by gg on 25/01/2018.
//  Copyright © 2018 ganyi. All rights reserved.
//

import Foundation
///宜忌
public struct Taboo{
    ///类型 1:宜 2:忌
    public var type = 1
    ///内容
    public var content = ""
    ///日期
    public var date = Date()
}

///节假日
public struct Holiday{
    ///id
    public var id = 0
    ///开始日期
    public var beginDate = Date()
    ///节日名
    public var name = ""
    ///放假或调休 1:放假 2:调休
    public var status = 1
    ///放假天数列表
    public var dayList = [Holiday]()
}

public struct CalendarModel{
    init(){}
    ///宜忌
    public var tabooList = [Taboo]()
    ///节假日
    public var holidayList = [Holiday]()
    ///节日节气
    public var festivalList = [FestivalModel]()
}


extension DataManager{
    
    ///获取万年历数据
    public func getCalendarData(withDate date: Date, closure: @escaping (CodeResult, String, CalendarModel)->()){
        let dic = ["beginDate": date.formatString(with: "yyyy") + "-01-01"]
        
        Session.session(withAction: Actions.getCalendarData, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                var calendarModel = CalendarModel()
                guard codeResult == .success else{
                    closure(.failure, message, calendarModel)
                    return
                }
                
                guard let dataDic = data as? [String: Any] else{
                    closure(.failure, "data json error", calendarModel)
                    return
                }
                
                //taboo
                if let tabooListData = dataDic["taboo"] as? [[String: Any]]{
                    for tabooData in tabooListData{
                        var taboo = Taboo()
                        taboo.content = tabooData["content"] as? String ?? ""
                        taboo.type = tabooData["tayp"] as? Int ?? 0
                        calendarModel.tabooList.append(taboo)
                    }
                }
                
                //holiday
                if let holidayListData = dataDic["holiday"] as? [[String: Any]]{
                    for holidayData in holidayListData{
                        let holiday = self.getHoliday(fromJson: holidayData)
                        calendarModel.holidayList.append(holiday)
                    }
                }
                
                //节日节气
                if let festivalListData = dataDic["festival"] as? [[String: Any]] {
                    for festivalData in festivalListData{
                        let festival = self.getFestivalModel(fromJSON: festivalData)
                        calendarModel.festivalList.append(festival)
                    }
                }
                
                //缓存到本地
                if let first = calendarModel.tabooList.first{
                    
                    let year = Calendar.current.component(.year, from: date)
                    self.localCalendarModel[year] = calendarModel
                }
                
                closure(.success, message, calendarModel)
            }
        }
    }
    
    //MARK:- 解析节假日
    func getHoliday(fromJson jsonData: [String: Any]) -> Holiday {
        let holidayData = jsonData

        var holiday = Holiday()
        holiday.id = holidayData["id"] as? Int ?? 0
        holiday.name = holidayData["name"] as? String ?? ""
        holiday.status = holidayData["status"] as? Int ?? 0
        if let dateStr = holidayData["date"] as? String{
            holiday.beginDate = Date(withDateStr: dateStr, withFormatStr: "yyyy-MM-dd")
        }
        if let dayListData = holidayData["holidayCalendarList"] as? [[String: Any]]{
            for dayData in dayListData{
                let day = getHoliday(fromJson: dayData)
                holiday.dayList.append(day)
            }
        }
        return holiday
    }
}
