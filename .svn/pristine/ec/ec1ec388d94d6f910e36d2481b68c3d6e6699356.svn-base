//
//  Color+Extension.swift
//  RemindData
//
//  Created by gg on 08/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
extension UIColor{
    convenience init(colorHex hex: UInt, alpha: CGFloat = 1) {
        var aph = alpha
        if aph < 0 {
            aph = 0
        }
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255,
                  green: CGFloat((hex & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(hex & 0x0000FF) / 255,
                  alpha: alpha)
    }
    
    convenience init(colorHexStr hexStr: String, alpha: CGFloat = 1){
        let t = UIColor.hexTorgb(hexStr, alpha: alpha)
        self.init(red: t[0], green: t[1],blue: t[2], alpha: t[3])
    }
    
    class func hexTorgb(_ rgbValue: String,alpha: CGFloat) -> [CGFloat] {
        var  Str :NSString = rgbValue.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) as NSString
        if rgbValue.hasPrefix("0x"){
            Str=(rgbValue as NSString).substring(from: 2) as NSString
        }else if rgbValue.hasPrefix("#"){
            Str=(rgbValue as NSString).substring(from: 1) as NSString
        }else{
            return [0, 0, 0, 0]
        }
        if Str.length != 6 {
            return [0, 0, 0, 0]
        }
        let red = (Str as NSString ).substring(to: 2)
        let green = ((Str as NSString).substring(from: 2) as NSString).substring(to: 2)
        let blue = ((Str as NSString).substring(from: 4) as NSString).substring(to: 2)
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string:red).scanHexInt32(&r)
        Scanner(string: green).scanHexInt32(&g)
        Scanner(string: blue).scanHexInt32(&b)
        return [CGFloat(r)/255.0, CGFloat(g)/255.0, CGFloat(b)/255.0, alpha]
    }
}
