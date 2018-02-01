//
//  SessionConfigure.swift
//  RemindData
//
//  Created by gg on 04/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation

public struct Urls {
    public static let host                 = "https://ios-api.mc.cn/restful/"
    public static let iconHost                 = "https://ios-api.mc.cn/"
}

//请求类型
enum RequestMethod: String {
    case post = "POST"
    case get = "GET"
}

//返回类型
public enum CodeResult{
    case success
    case failure
}

//Action类型
struct Actions {
    static let register                 = "member/register"                     //注册
    
    static let isWXBinded               = "member/weixin"                       //查询微信是否已绑定(绑定)
    static let bindWX                   = "member/bind/weixin"                  //绑定微信
    static let getEmailVerification     = "member/send/email"                   //发送邮件获取邮箱验证码
    static let bindEmail                = "member/bind/email"                   //绑定邮箱
    static let unbindWX                 = "member/unbind/weixin"                //解绑微信
    static let unbindEmail              = "member/unbind/email"                 //解绑邮箱
    
    static let getInfo                  = "member/info"                         //查询个人信息
    static let updatePhoneName          = "member/update/phone/name"            //修改手机名称
    
    static let getAddList               = "event/type/list"                     //获取所有可添加重要事件类型&每日提醒类型
    
    static let getAllEvents             = "event/list"                          //获取所有事件
    static let getEventInfo             = "event/info"                          //获取事件详情
    static let getEventPre              = "event/toadd"                         //预添加事件
    static let addEvent                 = "event/save"                          //添加事件
    static let getUpdateEventPre        = "event/toupdate"                      //预编辑事件
    static let updateEvent              = "event/update"                        //修改事件
    static let pauseEvent               = "event/pause"                         //暂停事件
    static let startEvent               = "event/start"                         //开始或重新开始事件
    static let deleteEvent              = "event/delete"                        //删除事件
    static let finishEvent              = "event/handle"                        //标记事件为已处理
    
    static let getAllEventClients       = "event/client/list"                   //获取所有每日提醒
    static let addEventClient           = "event/client/save"                   //添加或修改每日提醒
    static let startEventClient         = "event/client/start"                  //开始每日提醒
    static let pauseEventClient         = "event/client/pause"                  //暂停每日提醒
    static let deleteEventClient        = "event/client/delete"                 //删除每日提醒
    
    static let getAllNotices            = "notice/log/list"                     //获取所有提醒（根据Id获取最新列表）
    static let cancelNotice             = "notice/cancel"                       //不再提醒
    static let deleteNotice             = "notice/log/delete"                   //删除提醒
    static let deleteAllNotices         = "notice/log/deleteall"                //删除所有提醒
    static let getNewestNotices         = "notice/log/newestLogs"               //获取最新提醒消息
    static let getNoticesCount          = "notice/log/count"                    //获取新消息个数
    
    
    static let addFeedback              = "feedback/save"                       //保存反馈
    static let getLastVersion           = "app/version/latest"                  //获取app最新版本                 
    
    static let getCards                 = "index/data"                          //获取首页数据
    static let getCardSettings          = "tab/list"                            //获取卡片设置列表
    static let displayCard              = "tab/save"                            //显示卡片
    static let hideCard                 = "tab/delete"                          //隐藏卡片
    static let getCardDisplayModeList   = "tab/set/list"                        //获取卡片显示模式列表
    static let setCardDisplayMode       = "tab/update"                          //设置卡片显示方式
    static let setCardSort              = "tab/update/sort"                     //设置卡片排序
    
    static let updateStock              = "stock/index/real"                    //刷新股票信息
    static let saveStockSetting         = "stock/remind/set/save"               //保存股票设置
    static let getStockSetting          = "stock/remind/set/get"                //获取股票设置
    
    static let getWeatherInfo           = "weather/info"                        //获取天气详情
    static let getCityList              = "weather/city/list"                   //获取城市列表
    static let sortCity                 = "weather/city/sort"                   //排序城市
    static let getHotCityList           = "weather/city/hot/list"               //获取热门城市列表
    static let getMarkCityList          = "weather/user/city/list"              //获取用户收藏城市列表
    static let markCity                 = "weather/user/city/save"              //用户添加收藏城市
    static let unmarkCity               = "weather/user/city/delete"            //用户取消收藏城市
    static let markSingleCity           = "weather/user/city/single_save"       //用户添加单个收藏城市
    static let getWeatherSetting        = "weather/remind/set/get"              //获取用户天气提醒设置
    static let setWeatherSetting        = "weather/remind/set/save"             //保存用户天气提醒设置
    static let setLocationCity          = "weather/user/city/location/save"     //根据定位保存城市天气
    
    static let addStep                  = "member/step/save"                    //用户步数上传
    static let addSteps                 = "sport/step/batch/save"               //批量步数上传
    static let addTargetStep            = "member/step/set/save"                //保存用户目标步数
    static let getTargetStep            = "member/step/set/get"                 //获取用户目标步数
    static let getStepLog               = "sport/step/log"                      //获取历史步数列表
    static let getStepsDetailList       = "sport/step"                          //获取步数详情列表
    
    static let getAllFestivalList       = "festival/list"                       //获取节日列表
    static let getFestivalDetail        = "festival/detail"                     //获取节日详情
    static let getFestivalSetting       = "festival/tab_info"                   //获取节日设置
    static let setFestivalSetting       = "festival/tab_set"                    //修改节日设置
    static let getFestivalListByType    = "festival/type/festival_list"         //根据类型获取节日列表
    static let setSelectedFestival      = "festival/save"                       //设置关注节日
    
    static let getHolidaySetting        = "holiday/set/get"                     //获取节假日设置
    static let setHolidaySetting        = "holiday/set/save"                    //保存节假日设置
    
    static let getCalendarData          = "calendar/data"                       //获取万年历数据
}
