//
//  DM+Step.swift
//  RemindData
//
//  Created by gg on 11/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation

public struct StepsDetailModel{
    public init(){
        
    }
    public var highestStep = StepModel()
    public var todayStep = StepModel()
    public var log = [StepModel]()
}

public struct StepsSetting{
    public init(){}
    public var targetStep = 0
    public var targetDistanceM = 0
    public var targetCaloria = 0
    public var beginTime = Date()
    public var isEmailOpen = false
    public var isWeixinOpen = false
    public var ring = ""
    public var isPause = false
}

extension DataManager{
    ///用户步数上传？
    public func addStep(withSteps steps: Int, withDistanceM distanceM: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        let dic = [
            "steps": "\(steps)",
            "distance": "\(distanceM)"
        ]
        
        Session.session(withAction: Actions.addStep, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
    
    ///批量步数上传
    public func addSteps(withStepModelList stepModelList: [StepModel], closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        var jsonDicList = [[String: String]]()
        for stepModel in stepModelList{
            let jsonDic = [
                "step": "\(stepModel.step)",
                "distance": "\(stepModel.distanceM)",
                "createTime": "\(Int(stepModel.date.timeIntervalSince1970 * 1000))"
            ]
            jsonDicList.append(jsonDic)
        }        
        let dic = ["data": jsonDicList]
        Session.session(withAction: Actions.addSteps, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
    
    //MARK:- 保存目标步数
    public func addTargetStep(withStepsSetting stepsSetting: StepsSetting, closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        let dic: [String: Any] = [
            "targetStep": "\(stepsSetting.targetStep)",
            "targetDistance": "\(stepsSetting.targetDistanceM)",
            "targetCal": "\(stepsSetting.targetCaloria)",
            "beginTime": stepsSetting.beginTime.formatString(with: "H:mm"),
            "byEmail": stepsSetting.isEmailOpen ? 1 : 0,
            "byWeixin": stepsSetting.isWeixinOpen ? 1 : 0,
            "ring": stepsSetting.ring,
            "status": stepsSetting.isPause ? 1 : 0
        ]
        
        Session.session(withAction: Actions.addTargetStep, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
    
    //MARK:- 获取步数设置
    public func getTargetStep(closure: @escaping (_ codeResult: CodeResult, _ message: String, _ stepsSetting: StepsSetting)->()){
        Session.session(withAction: Actions.getTargetStep, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            DispatchQueue.main.async {
                var stepsSetting = StepsSetting()
                guard codeResult == .success else{
                    closure(.failure, message, stepsSetting)
                    return
                }
                
                guard let dataDic = data as? [String: Any] else{
                    closure(.failure, "error json data", stepsSetting)
                    return
                }
                
                stepsSetting.targetStep = dataDic["targetStep"] as? Int ?? 0
                stepsSetting.targetDistanceM = dataDic["targetDistance"] as? Int ?? 0
                if let targetCaloria = dataDic["targetCal"] as? Double{
                    stepsSetting.targetCaloria = Int(targetCaloria)
                }
                if let timeStr = dataDic["beginTime"] as? String{
                    stepsSetting.beginTime = Date(withDateStr: timeStr, withFormatStr: "H:m")
                }
                stepsSetting.isWeixinOpen = dataDic["byWeixin"] as? Bool ?? false
                stepsSetting.isEmailOpen = dataDic["byEmail"] as? Bool ?? false
                stepsSetting.ring = dataDic["ring"] as? String ?? ""
                if let status = dataDic["status"] as? Int{
                    stepsSetting.isPause = status == 1
                }
                
                closure(.success, message, stepsSetting)
            }
        }
    }
    
    ///获取历史步数(按日期分页)
    public func getStepLogList(withPage page: Int, withPageSize pageSize: Int, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ stepModelList: [StepModel])->()){
        let dic = [
            "page": "\(page)",
            "pageSize": "\(pageSize)"
        ]
        
        Session.session(withAction: Actions.getStepLog, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard codeResult == .success else{
                    closure(.failure, message, [])
                    return
                }
                
                guard let dicListData = data as? [[String: Any]] else{
                    closure(.failure, "data json error", [])
                    return
                }
                
                var list = [StepModel]()
                for dicData in dicListData{
                    var stepModel = StepModel()
                    stepModel.step = dicData["step"] as? Int ?? 0
                    stepModel.distanceM = dicData["distance"] as? Int ?? 0
                    if let createTime = dicData["createTime"] as? TimeInterval{
                        stepModel.date = Date(timeIntervalSince1970: createTime / 1000)
                    }
                    list.append(stepModel)
                }
                closure(.success, message, list)
                
            }
        }
    }
    
    ///获取步数列表详情
    public func getStepsDetailLogList(withBeginDate beginDate: Date, withEndDate endDate: Date, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ stepDetailModel: StepsDetailModel)->()){
        let dic = [
            "startDate": beginDate.formatString(with: "yyyy-MM-dd"),
            "endDate": endDate.formatString(with: "yyyy-MM-dd")
        ]
        
        Session.session(withAction: Actions.getStepsDetailList, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                
                var stepsDetailModel = StepsDetailModel()
                
                guard codeResult == .success else{
                    closure(.failure, message, stepsDetailModel)
                    return
                }
                
                guard let dicData = data as? [String: Any] else{
                    closure(.failure, "data json error", stepsDetailModel)
                    return
                }
                
                //最高记录
                stepsDetailModel.highestStep = self.getStepModel(fromJsonData: dicData["highest"])
                
                //今日
                stepsDetailModel.todayStep = self.getStepModel(fromJsonData: dicData["today"])
                
                //范围列表
                if let logsData = dicData["log"] as? [[String: Any]]{
                    for logData in logsData{
                        let model = self.getStepModel(fromJsonData: logData)
                        stepsDetailModel.log.append(model)
                    }
                }
                
                closure(.success, message, stepsDetailModel)
            }
        }
    }
    
    
    
    
    
    
    
    //******************************************************************************************************************************************************
    //MARK:- 解析StepModel数据
    func getStepModel(fromJsonData jsonData: Any?) -> StepModel{
        var stepModel = StepModel()
        guard let dicData = jsonData as? [String: Any] else{
            return stepModel
        }
        
        stepModel.step = dicData["step"] as? Int ?? 0
        stepModel.distanceM = dicData["distance"] as? Int ?? 0
        if let createTime = dicData["createTime"] as? TimeInterval{
            stepModel.date = Date(timeIntervalSince1970: createTime / 1000)
        }
        stepModel.caloria = dicData["cal"] as? Int ?? 0
        stepModel.targetStep = dicData["targetStep"] as? Int ?? 0
        return stepModel
    }
}
