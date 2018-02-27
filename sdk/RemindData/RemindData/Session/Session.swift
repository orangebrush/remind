//
//  Session.swift
//  RemindData
//
//  Created by gg on 04/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
typealias Closure = (_ codeResult: CodeResult, _ message:String, _ data: Any?) -> ()
class Session {
    class func session(withAction action: String, withRequestMethod requestMethod: RequestMethod, withParam param: [String: Any], closure: @escaping Closure) {
        
        //回调函数
        let completionHandler = {(binaryData: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else{
                
                closure(CodeResult.failure, "连接服务器错误", nil)
                debugPrint("<Session> 请求错误: \(String(describing: error))")
                return
            }
            
            do{
                //服务器关闭的情况
                if let statusCode = response?.value(forKey: "statusCode") as? Int{
                    if statusCode == 502{
                        closure(.failure, "服务未开启", nil)
                        return
                    }
                }
                
                guard let result = try JSONSerialization.jsonObject(with: binaryData!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else{
                    closure(CodeResult.failure, "获取数据错误", nil)
                    return
                }
                
               debugPrint(result)
                
                guard let code = result["code"] as? Int, let message = result["message"] as? String else {
                    closure(CodeResult.failure, "解析数据错误", nil)
                    return
                }
                
                //"0"成功 "-1"其他错误
                if let data = result["data"]{
                    closure(code == 0 ? .success : .failure, message, data)
                }else{
                    closure(code == 0 ? .success : .failure, message, nil)
                }
            }catch let responseError{
                closure(CodeResult.failure, "数据处理错误", nil)
                debugPrint("<Session> 数据处理错误: \(responseError)")
            }
        }
        
        guard DataManager.share().isNetworkEnable() else {
            closure(.failure, "网络不可用", nil)
            return
        }
        
        //post or get
        let isPost = requestMethod == .post
        do{
            var tempParam = param
            tempParam["idfa"] = MemberManager.share().idfa
            
            var urlStr = Urls.host + action
            if !isPost {
                tempParam["uid"] = MemberManager.share().member?.uuid ?? ""
                for (offset: index, element: (key: key, value: value)) in tempParam.enumerated(){
                    if index == 0{
                        urlStr += "?"
                    }else{
                        urlStr += "&"
                    }
                    let v = value as! String
                    urlStr.append(key + "=" + v)
                }
            }
            
            //生成url
            guard let url = URL(string: urlStr) else{
                return
            }
            
            
            let session = URLSession.shared
            var task: URLSessionDataTask
            if isPost {
                var request: URLRequest!
                if isPost {
                    request =  URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
                    request.httpMethod = requestMethod.rawValue
                    
                    if action != Actions.register{
                        //为获取到uuid则禁止做其他请求
                        if let uuid = MemberManager.share().uuid, uuid != ""{
                            tempParam["uid"] = uuid
                        }else{
                            DataManager.share().register(closure: { (result, message, uid) in
                                if result == .failure{
                                    closure(CodeResult.failure, message, nil)
                                    return
                                }
                            })
                            return
                            //tempParam["uid"] = ""
                        }
                    }
                    let originBodyData = try JSONSerialization.data(withJSONObject: tempParam, options: .prettyPrinted)
                    
                    
                    let bodyStr = String(data: originBodyData, encoding: .utf8)?.encrypt().escape()
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("1", forHTTPHeaderField: "IS-IOS")
                    request.httpBody = bodyStr?.data(using: .utf8)
                }
                task = session.dataTask(with: request, completionHandler: completionHandler)
            }else{
                task = session.dataTask(with: url, completionHandler: completionHandler)
            }
            task.resume()
        }catch let error{
            debugPrint("<Session> 解析二进制数据错误: \(error)")
        }
    }
    
    //MARK:-上传图片
    class func upload(_ image: UIImage, userid: String, closure: @escaping Closure){
        //回调函数
        let completionHandler = {(binaryData: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else{
                closure(.failure, "error", nil)
                debugPrint("<Session> 请求错误: \(String(describing: error))")
                return
            }
            
            do{
                guard let result = try JSONSerialization.jsonObject(with: binaryData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else{
                    closure(.failure, "获取数据错误", nil)
                    return
                }
                
                debugPrint("<Session> result: \(result)")
                
                guard let code = result["code"] as? Int, let message = result["message"] as? String else {
                    closure(.failure, "解析数据错误", nil)
                    return
                }
                
                if let data = result["data"]{
                    closure(code == 200 ? .success : .failure, message, data)
                }else{
                    closure(code == 200 ? .success : .failure, message, nil)
                }
            }catch let responseError{
                debugPrint("<Session> 数据处理错误: \(responseError)")
            }
        }
        
        //上传
        guard let imgData = UIImagePNGRepresentation(image) else {
            return
        }
        
        let urlStr = Urls.host + Actions.register
        
        //生成url
        guard let url = URL(string: urlStr) else{
            return
        }
        
        let boundary = "gansdlfajlsjdfa12"
        let headerString = "multipart/form-data; charset=utf-8; boundary=" + boundary
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = "POST"
        
        request.setValue(headerString, forHTTPHeaderField: "Content-Type")
        
        var mutableData = Data()
        var myString = "--" + boundary + "\r\n"
        myString += "Content-Disposition: form-data; name=\"userId\"\r\n"
        myString += "Content-Type: text/plain; charset=UTF-8\r\n"
        myString += "Content-Transfer-Encoding: 8bit\r\n\r\n"
        myString += userid
        
        myString += "\r\n--" + boundary + "\r\n"
        myString += "Content-Disposition: form-data; name=\"file\"; filename=\"" + userid + ".png\"\r\n"
        myString += "Content-Type: image/png\r\n"
        myString += "Content-Transfer-Encoding: binary\r\n\r\n"
        
        mutableData.append(myString.data(using: .utf8)!)
        mutableData.append(imgData)
        mutableData.append(("\r\n--" + boundary + "--\r\n").data(using: .utf8)!)
        
        request.httpBody = mutableData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        
    }
}
