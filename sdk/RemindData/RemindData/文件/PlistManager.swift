//
//  PlistManager.swift
//  RemindData
//
//  Created by gg on 19/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
final class PlistManager: NSObject {
    
    //MARK:- class init *****************************************************************************************************
    struct singleton{
        static var instance = PlistManager()
    }
    public class func share() -> PlistManager{
        return singleton.instance
    }
    
    //key
    let lastEventClientId = "lastEventClientId"
    
    //file name
    let fileName = "SDKInfo"
    //file bundle's path
    var filePath: String!{
        return Bundle.main.path(forResource: "/Frameworks/RemindData.framework/" + fileName, ofType: "plist")!
    }
    
    //MARK:- 获取文档路径
    func documentPath() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        return path + "/" + fileName + ".plist"
    }
    
    //MARK:- 读取文档信息
    func readDictionary() -> [String: Int]{
        let fileManager = FileManager.default
        let fileExist = fileManager.fileExists(atPath: documentPath())
        var dictionary: NSDictionary!
        if fileExist {
            dictionary = NSDictionary(contentsOfFile: documentPath())
        }else{
            dictionary = NSDictionary(contentsOfFile: filePath)
        }
        
        var result = [String: Int]()
        for element in dictionary{
            guard let key = element.key as? String, let value = element.value as? Int else{
                continue
            }
            result[key] = value
        }
        return result
    }
    
    ///强制重置lastId
    func setLastId(withNewLastId newLastId: Int){
        var result = readDictionary()
        if let oldLastId = result[lastEventClientId]{
            if oldLastId < newLastId{
                result[lastEventClientId] = newLastId
                let newResult = NSDictionary(dictionary: result)
                newResult.write(toFile: documentPath(), atomically: true)
            }
        }
    }
    
    ///每日提醒数据库自增 ++
    @discardableResult
    func add() -> Bool{
        var result = readDictionary()
        if let lastId = result[lastEventClientId]{
            result[lastEventClientId] = lastId + 1
        }
        let newResult = NSDictionary(dictionary: result)
        return newResult.write(toFile: documentPath(), atomically: true)
    }
    
    ///获取新建每日提醒所需的id
    func getNewEventClientId() -> Int{
        var result = readDictionary()
        if let lastId = result[lastEventClientId]{
            return lastId + 1
        }
        return 0
    }
}
