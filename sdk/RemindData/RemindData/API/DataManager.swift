//
//  DataManager.swift
//  RemindData
//
//  Created by gg on 04/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation

public final class DataManager: NSObject {
    //MARK:- class init *****************************************************************************************************
    struct singleton{
        static var instance = DataManager()
    }
    
    @discardableResult
    public class func share() -> DataManager{
        return singleton.instance
    }
    
    //MARK:- 监测网络是否可用
    public func isNetworkEnable() -> Bool{
        guard let reachability = Reachability() else{
            debugPrint("<Reachability> 生成网络监测失败")
            return false
        }
        
        //判断连接类型
        if reachability.isReachableViaWiFi {
            debugPrint("<reachability> type: WiFi")
        }else if reachability.isReachableViaWWAN {
            debugPrint("<reachability> type: 移动网络")
        }else {
            debugPrint("<reachability> type: 没有网络连接")
        }
        
        //判断连接状态
        if reachability.isReachable{
            debugPrint("<reachability> state: 网络可用")
            return true
        }else{
            debugPrint("<reachability> state: 网络不可用")
            return false
        }
    }
    
    ///节日节气、法定节假日数据 key: 年份 value: 模型
    public var localCalendarModel = [Int: CalendarModel](){
        didSet{
            holidayMap.removeAll()
            festivalMap.removeAll()
            for (_, list) in localCalendarModel{
                for holiday in list.holidayList{
                    holidayMap[holiday.beginDate] = holiday
                }
                for festival in list.festivalList{
                    //进行时间对比（需与获取的时间格式相同）
                    let oldDate = festival.date
                    let year = Calendar.current.component(.year, from: oldDate)
                    let month = Calendar.current.component(.month, from: oldDate)
                    let day = Calendar.current.component(.day, from: oldDate)
                    let newDate = Date(withDateStr: "\(year)-\(month)-\(day)", withFormatStr: "yyy-M-d")
                    festivalMap[newDate] = festival
                }
            }
        }
    }
    
    ///节假日字典
    public var holidayMap = [Date: Holiday]()
    
    ///节日节气字典
    public var festivalMap = [Date: FestivalModel]()
}
