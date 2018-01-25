//
//  UserInfoModel.swift
//  RemindData
//
//  Created by gg on 04/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
public protocol CardProtocal{
    
}
public enum CardType{
    case weather(String, [WeatherModel])
    case festival(String, [FestivalModel])
    case birthday(String, [BirthdayModel])
    case event(String, [EventModel])
    case stock(String, [StockModel])
    
    ///获取名称
    public func name() -> String{
        let result: String
        switch self {
        case .weather(let n, _):
            result = n
        case .festival(let n, _):
            result = n
        case .birthday(let n, _):
            result = n
        case .event(let n, _):
            result = n
        case .stock(let n, _):
            result = n
        }
        return result
    }
    
    ///获取对应数组(需解析类型)
    public func list() -> [Any]{
        let result: [Any]
        switch self {
        case .weather(_, let l):
            result = l
        case .festival(_, let l):
            result = l
        case .birthday(_, let l):
            result = l
        case .event(_, let l):
            result = l
        case .stock(_, let l):
            result = l
        }
        return result
    }
}

//首页返回的所有数据
public struct Card{
    public var type: CardType?
}

public enum CardSettingType: Int{
    case weather = 1, festival, birthday, event, eventClient, stock, steps
}


///卡片显示模式
public struct CardSet{
    ///id
    public var id = 0
    ///是否为默认选择
    public var isDefault = false
    ///显示文字
    public var remark = ""
}
///卡片设置信息
public struct CardSetting{
    ///tabId
    public var id = 0
    ///卡片名称
    public var name = ""
    ///卡片类型
    public var type = CardSettingType.weather
    ///显示或隐藏
    public var isDisplay = false
    ///卡片说明
    public var introduce = ""
    ///卡片图标
    public var icon = ""
}
//所有卡片设置
public struct CardSettings{
    public var use = [CardSetting]()
    public var notUse = [CardSetting]()
}

///天气城市
public struct City{
    public var id = 0
    public var name = ""
    public var parentId = 0
    public var followed = false
}
///空气质量模型
public struct AqiInfoModel {
    public var level = ""          //级别
    public var color = UIColor(colorHexStr: "#FFFF00")   //颜色
    public var affect = ""         //影响提示
    public var measure = ""        //注意事项
}
///天气模型
public struct WeatherModel {
    ///日期字符串
    public var date = ""
    ///城市
    public var city = City()
    ///星期
    public var week = ""
    ///农历
    public var lunar = ""
    ///天气
    public var weather = ""
    ///温度
    public var temp = 0
    ///最高温
    public var tempHigh = 0
    ///最低温
    public var tempLow = 0
    ///空气质量指数
    public var aqi = 0
    ///空气质量详情
    public var aqiInfo = AqiInfoModel()
    ///图片名称
    public var imgNum = 0
    ///未来天气列表2~7天
    public var dailyList = [WeatherModel]()
}

//节日类型
public enum FestivalType: Int{
    //传统节日（默认），国际节日，事件节日，网络节日，二十四节气
    case tradition = 0, international, event, network, solarTerms
}

//步数模型
public struct StepModel{
    ///目标步数
    public var targetStep = 0
    ///当前步数
    public var step = 0
    ///当前距离
    public var distanceM = 0
    ///当前卡路里
    public var caloria = 0
}

//节日模型
public struct FestivalModel {
    ///节日id
    public var id = 0
    ///节日名称
    public var name = ""
    ///节日类型
    public var type = FestivalType.tradition
    ///节日图标
    public var icon = ""
    ///节日介绍
    public var introduction = ""
    ///节日习俗
    public var custom = ""
    ///节日养生
    public var health = ""
    ///节日背景图
    public var bgImg = ""
    ///日期
    public var date = Date()
    ///剩余天数
    public var leftDay = ""
}

//生日模型
public struct BirthdayModel {
    public var id = 0
    ///类型
    public var type = 0
    ///人名
    public var introduce = ""
    ///日期字符串
    public var formalText = ""
    ///文字1 剩余天数
    public var intervalDayText = ""
    ///文字2 距离下次提醒
    public var intervalText = ""
}

//重要事件模型
public struct EventModel {
    public var id = 0
    ///类型
    public var type = 0
    ///事件名
    public var introduce = ""
    ///日期
    public var date = Date()
    ///提醒时间
    public var formalTimeText = ""
    ///文字1 剩余天数
    public var intervalDayText = ""
    ///文字2 距离下次提醒
    public var intervalText = ""
}

//股票
public struct StockModel {
    ///股票名
    public var prodName = ""
    ///地区号
    public var prefix = ""
    ///股票代码
    public var prodCode = ""
    ///涨跌幅
    public var pxChange: Double = 0
    ///涨跌率
    public var pxChangeRate: Double = 0
    ///最新价格
    public var lastPx: Double = 0
}


//MARK:- 读取城市列表文件
func readCityFile() -> [City]{
    var cityList = [City]()
    
    guard let path = Bundle.main.path(forResource: "Frameworks/RemindData.framework/cityList", ofType: "txt") else{
        return cityList
    }
    
    do{
        let str = try String(contentsOfFile: path, encoding: .utf8)
        guard let data = str.data(using: .utf8) else{
            return cityList
        }
        guard let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else{
            debugPrint("获取城市数据错误")
            return cityList
        }
        
        guard let citysData = result["data"] as? [[String: Any]] else {
            return cityList
        }
        
        cityList = getCityList(fromJSON: citysData)        
        
        return cityList
    }catch let error{
        debugPrint("city file error: \(error)")
    }
    return []
}

//MARK:- 解析城市数据
func getCityList(fromJSON jsonData: [[String: Any]]) -> [City]{
    var cityList = [City]()
    for cityData in jsonData{
        var city = City()
        city.id = cityData["id"] as? Int ?? 0
        city.name = cityData["name"] as? String ?? ""
        city.parentId = cityData["parentid"] as? Int ?? 0
        if let followFlag = cityData["followFlag"] as? Int{
            city.followed = followFlag == 1
        }
        cityList.append(city)
    }
    return cityList
}
