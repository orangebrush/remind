//
//  String+Extension.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

fileprivate let TAG_PUBLIC_KEY = "com.batour.bpk1"
fileprivate let RSA_MAX = 117
fileprivate let pubStr = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCuVM1W7a6sDEjCV46xfLBSdyhlKY0dvXOTR63WXmGYXvd7waiseTKGurz97Cux80xJqFe7Z1EVHbqlRlw+f0YRNaR4tkqVWVAgbE5mh2GJVbM/ulO3821f9uWuoovuQji7IiycTN33eC9vEtvSA9ikF0eGLpfRIRTbu10S4JCMYwIDAQAB"

import Foundation
extension String{
    
    func hexStringToInt() -> UInt32 {
        let str = self.uppercased()
        var sum: UInt32 = 0
        for i in str.utf8 {
            sum = sum * 16 + UInt32(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
    
    //MARK:- 验证是否为邮箱
    func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    //MARK:- rsa enctypt
    func encrypt() -> String{
        //暂时启用rsa
        return self.data(using: .utf8)?.base64EncodedString() ?? ""
        
        var bytesRead = 0
        var reachEnd: Bool = false
        var encryptData: Data? = Data.init()
        
        while !reachEnd {
            var end: Int  = 0
            if self.count - bytesRead < RSA_MAX{
                end = self.count
                reachEnd = true
            }else{
                end = bytesRead + RSA_MAX
            }
            let tmpStr =  substring(start: bytesRead, end: end)
            if tmpStr.count != 0{
                let encryptedData = RSAUtils.encryptWithRSAPublicKey(tmpStr.data(using: .utf8)!, pubkeyBase64: pubStr, keychainTag: TAG_PUBLIC_KEY)
                if let data = encryptedData{
                    encryptData?.append(data)
                    bytesRead = bytesRead + RSA_MAX
                }else{
                    print(self)
                    NSLog("====RSA加密崩溃了=====")
                }
            }
        }
        
        return encryptData!.base64EncodedString()
    }
    
    //MARK:- 截取字符串
    func substring(start: Int, end: Int) -> String {
        if start < 0 || end > count {
            return ""
        }
        let newStartIndex = index(startIndex, offsetBy: start)
        let newEndIndex = index(startIndex, offsetBy: end)
        let range = newStartIndex..<newEndIndex
        return String(self[range])

    }
    
    func escape() -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;"
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F,     // Emoticons
                 0x1F300...0x1F5FF,     // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF,     // Transport and Map
                 0x2600...0x26FF,       // Misc symbols
                 0x2700...0x27BF,       // Dingbats
                 0xFE00...0xFE0F:       // Variation Selectors
                return true
            default:
                continue
            }
        }
        return false
    }
}
