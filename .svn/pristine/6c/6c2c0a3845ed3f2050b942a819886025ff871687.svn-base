//
//  DM+Binding.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
extension DataManager{
    
    //MARK:- 查询是否绑定微信
    public func isWXBinded(withCode code: String, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ isBinded: Bool)->()){
        let dic = [
            "code": code
        ]
        
        Session.session(withAction: Actions.isWXBinded, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            guard let isBinded = (data as? [String: Any])?["has"] as? Int else{
                DispatchQueue.main.async {
                    closure(.failure, message, false)
                }
                return
            }
            
            DispatchQueue.main.async {
                //“0”未绑定过，“1”有设备绑定过
                closure(codeResult, message, isBinded == 1)
            }
        }
    }
    
    //MARK:- 绑定微信
    public func bindWX(withCode code: String, withSync sync: Bool, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ wxNickName: String?, _ wxAvatar: URL?)->()){
        let dic = [
            "code": code,
            "sync": sync ? "1" : "0"
        ]
        Session.session(withAction: Actions.bindWX, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard let dataDic = data as? [String: String] else{
                    closure(.failure, message, nil, nil)
                    return
                }
                
                guard let nickName = dataDic["wxNickName"],
                    let avatar = dataDic["wxAvatar"] else{
                        closure(.failure, "微信内容解析失败", nil, nil)
                        return
                }
                
                guard let url = URL(string: avatar) else{
                    closure(.success, message, nickName, nil)
                    return
                }
                closure(.success, message, nickName, url)
            }
        }
    }
    
    //MARK:- 绑定邮箱获取验证码
    public func getEmailVerification(withEmail email: String, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ address: String)->()){
        let dic = [
            "email": email
        ]
        
        Session.session(withAction: Actions.getEmailVerification, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            guard let address = (data as? [String: Any])?["address"] as? String else{
                DispatchQueue.main.async {
                    closure(.failure, message, "")
                }
                return
            }
            
            DispatchQueue.main.async {
                closure(codeResult, message, address)
            }
        }
    }
    
    //MARK:- 绑定邮箱
    public func bindEmail(withEmailVerification emailVerification: String, closure: @escaping (_ codeResult: CodeResult, _ message: String, _ email: String?)->()){
        let dic = [
            "code": emailVerification
        ]
        
        Session.session(withAction: Actions.bindEmail, withRequestMethod: .post, withParam: dic) { (codeResult, message, data) in
            DispatchQueue.main.async {
                guard let dataDic = data as? [String: Any] else{
                    closure(.failure, message, nil)
                    return
                }
                closure(codeResult, message, dataDic["email"] as? String)
            }
        }
    }
    
    //MARK:- 解绑微信
    public func unbindWX(closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        Session.session(withAction: Actions.unbindWX, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
    
    //MARK:- 解绑邮箱
    public func unbindEmail(closure: @escaping (_ codeResult: CodeResult, _ message: String)->()){
        Session.session(withAction: Actions.unbindEmail, withRequestMethod: .post, withParam: [:]) { (codeResult, message, data) in
            DispatchQueue.main.async {
                closure(codeResult, message)
            }
        }
    }
}
