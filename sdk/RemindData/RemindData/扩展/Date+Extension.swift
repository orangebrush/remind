//
//  Date+Extension.swift
//  RemindData
//
//  Created by gg on 06/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
extension Date {
    ///格林威治时间转换
    public func GMT() -> Date{
        let zone = TimeZone.current
        let deltaTime: TimeInterval = TimeInterval(zone.secondsFromGMT(for: self))
        return self.addingTimeInterval(deltaTime)
    }
    
    
    public init(withDateStr dateStr: String, withFormatStr formatStr: String = "yyyy-MM-dd"){
        let formatter = DateFormatter()
        formatter.dateFormat = formatStr
        self = formatter.date(from: dateStr) ?? Date()
    }
    
    //转换为字符串
    public func formatString(with dateFormat: String) -> String{
        let format = DateFormatter()
        format.dateFormat = dateFormat
        return format.string(from: self)
    }
    
    //获取星期字符串
    public func weekdayString() -> String{
        let list = ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
        return list[weekday() - 1]
    }
    
    //判断是否为当前
    public func isToday() -> Bool{
        let dateFormat = "yyy-M-d"
        let str = formatString(with: dateFormat)
        let todayStr = Date().formatString(with: dateFormat)
        return str == todayStr
    }
    
    ///判断是否为当年
    public func isCurYear() -> Bool{
        let dateFormat = "yyy"
        let str = formatString(with: dateFormat)
        let todayStr = Date().formatString(with: dateFormat)
        return str == todayStr
    }
    
    //获取星期 1234567
    public func weekday() -> Int{
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
    
    //偏移
    public func offset(with offsetDay: Int, withTime timeFlag: Bool = false) -> Date {
        let resultDate = Date(timeInterval: TimeInterval(offsetDay) * 60 * 60 * 24, since: self)
        
        if timeFlag {
            return resultDate
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: resultDate)
        return calendar.date(from: components)!
    }
    
    ///拼接时间
    public func appendTime(withHour hour: Int, withMinute minute: Int) -> Date{
        var  components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        components.hour = hour
        components.minute = minute
        components.second = 0
        let newDate = Calendar.current.date(from: components)
        
        return newDate ?? self
    }
    
    ///计算间隔时间
    public func intervalDay(fromDate date: Date = Date()) -> Int{
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: date2, to: date1)
        return components.day ?? 0
    }
}
