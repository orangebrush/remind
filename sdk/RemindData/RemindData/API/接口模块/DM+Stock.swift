//
//  DM+Stock.swift
//  RemindData
//
//  Created by gg on 03/01/2018.
//  Copyright © 2018 ganyi. All rights reserved.
//

import Foundation
///股票设置模型
public struct StockSetting{
    ///开盘是否提醒
    public var isOpenStatus = false
    ///开盘提示音
    public var openRing = "Ring Ring Ring"
    ///开盘预提醒
    public var openBeginning = BeginningModel()
    ///收盘是否提醒
    public var isCloseStatus = false
    ///收盘提示音
    public var closeRing = "Ring Ring Ring"
    ///收盘预提醒
    public var closeBeginning = BeginningModel()
    ///是否微信提醒
    public var isWeixinOpen = false
    ///是否邮箱提醒
    public var isEmailOpen = false
    ///涨跌率
    public var changeRate: Double = 0
    ///涨跌率提醒音
    public var changeRing = "Ring Ring Ring"
    ///涨跌率是否提醒
    public var isChangeStatus = false
    ///设置选择的选项id
    public var selectedId = 0
    ///已选项
    public var remarkedName = ""
    ///选项
    public var remarkList = [StockRemark]()
}

///股票选项
public struct StockRemark{
    ///选项id
    public var id = 0
    ///选项名
    public var name = ""
    ///是否被选中
    public var isSelected = false
}

extension DataManager{
    
    ///定时刷新股票信息 3s
    public func updateStock(closure: @escaping (_ codeResult: CodeResult, _ message: String, _ stockModelList: [StockModel])->()){
        Session.session(withAction: Actions.updateStock, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard codeResult == .success else{
                    closure(.failure, message, [])
                    return
                }
                
                guard let dicData = data as? [String: Any] else{
                    closure(.failure, "股票结构解析错误", [])
                    return
                }
                guard let stockData = dicData["stock"] as? [String: Any] else{
                    closure(.failure, "股票数组解析错误", [])
                    return
                }
                guard let stockListData = stockData["data"] as? [[String: Any]] else{
                    closure(.failure, "股票数组解析错误", [])
                    return
                }
                
                let stockList = self.getStockModel(fromJSON: stockListData)
                closure(.success, message, stockList)
            }
        }
    }
    
    ///股票设置保存
    public func saveStockSetting(withStockSetting stockSetting: StockSetting, closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        let dic: [String: Any] = [
            "openStatus": stockSetting.isOpenStatus,
            "openRing":stockSetting.openRing,
            "openBeginning": stockSetting.openBeginning.encoderList(),
            "closeRing": stockSetting.closeRing,
            "closeStatus": stockSetting.isCloseStatus,
            "closeBeginning": stockSetting.closeBeginning.encoderList(),
            "byWeixin": stockSetting.isWeixinOpen,
            "byEmail": stockSetting.isEmailOpen,
            "changeRate": stockSetting.changeRate,
            "changeRing": stockSetting.changeRing,
            "changeStatus": stockSetting.isChangeStatus,
            "setId": stockSetting.selectedId                //选中的选项id
        ]
        Session.session(withAction: Actions.saveStockSetting, withRequestMethod: .post, withParam: dic) { (codeResult, message, _) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
    
    ///获取股票设置模型
    public func getStockSetting(closure: @escaping (_ codeResult: CodeResult, _ message: String, _ stockSetting: StockSetting)->()){
        Session.session(withAction: Actions.getStockSetting, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            var stockSetting = StockSetting()
            DispatchQueue.main.async {
                guard codeResult == .success else{
                    closure(.failure, message, stockSetting)
                    return
                }
                
                guard let dataDic = data as? [String: Any] else{
                    closure(.failure, "stockSetting json error", stockSetting)
                    return
                }
                stockSetting.openRing = dataDic["openRing"] as? String ?? ""
                stockSetting.isOpenStatus = dataDic["openStatus"] as? Bool ?? false
                if let beginning = dataDic["openBeginning"] as? String{
                    stockSetting.openBeginning.list = self.decoderBeginningList(withBeginningStr: beginning)
                }
                stockSetting.closeRing = dataDic["closeRing"] as? String ?? ""
                stockSetting.isCloseStatus = dataDic["closeStatus"] as? Bool ?? false
                if let beginning = dataDic["closeBeginning"] as? String{
                    stockSetting.closeBeginning.list = self.decoderBeginningList(withBeginningStr: beginning)
                }
                stockSetting.isWeixinOpen = dataDic["byWeixin"] as? Bool ?? false
                stockSetting.isEmailOpen = dataDic["byEmail"] as? Bool ?? false
                stockSetting.changeRate = dataDic["changeRate"] as? Double ?? 0
                stockSetting.changeRing = dataDic["changeRing"] as? String ?? ""
                stockSetting.isChangeStatus = dataDic["changeStatus"] as? Bool ?? false
                stockSetting.remarkedName = dataDic["setRemark"] as? String ?? ""
                stockSetting.selectedId = dataDic["setId"] as? Int ?? 0
                if let tabSetList = dataDic["tabSetList"] as? [[String: Any]]{
                    for tabSet in tabSetList{
                        var remind = StockRemark()
                        remind.id = tabSet["id"] as? Int ?? 0
                        remind.name = tabSet["remark"] as? String ?? ""
                        remind.isSelected = tabSet["choiceFlag"] as? Bool ?? false
                        stockSetting.remarkList.append(remind)
                    }
                }
                closure(.success, message, stockSetting)
            }
        }
    }
}
