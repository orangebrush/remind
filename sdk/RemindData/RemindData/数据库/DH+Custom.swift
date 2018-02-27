//
//  DH+Custom.swift
//  RemindData
//
//  Created by gg on 12/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
public enum CustomType{
    case colors([UIColor?])
    case img(UIImage?)
}



extension DataHandler{
    static var localCustom: Custom?
    
    //MARK:- 获取自定义
    func getCustom() -> Custom?{
        if DataHandler.localCustom != nil {
            return DataHandler.localCustom
        }
        DataHandler.localCustom = getMember()?.custom
        return DataHandler.localCustom
    }
    
    ///设置自定义颜色或者图片： customType:自定义数据（无自定义数据则传对应类型） index: 标记
    public func setCustom(withCustomType customType: CustomType, withIndex index: Int? = nil) -> Bool {
        guard let custom = getCustom() else{
            return false
        }
        
        custom.isCustom = index == nil
        custom.index = Int32(index ?? 0)
        
        switch customType {
        case .colors(let colors):
            custom.isImage = false
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            var red1: CGFloat = 0
            var green1: CGFloat = 0
            var blue1: CGFloat = 0
            var alpha1: CGFloat = 0
            if index == nil {
                if colors.count == 2 {
                    colors[0]?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    colors[1]?.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
                    custom.r = Float(red)
                    custom.g = Float(green)
                    custom.b = Float(blue)
                    custom.a = Float(alpha)
                    custom.r1 = Float(red1)
                    custom.g1 = Float(green1)
                    custom.b1 = Float(blue1)
                    custom.a1 = Float(alpha1)
                }else {
                    print("需传入两个颜色值")
                    return false
                }
            }
            return commit()
        case .img(let img):
            custom.isImage = true
            
            guard let image = img else{
                return false
            }
            
            //处理图片默认右旋转问题
            if image.imageOrientation == .right{
                
                let imageSize = image.size
                
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: 0, y: imageSize.height)
                transform = transform.rotated(by: -.pi / 2)
                
                guard let ctx = CGContext(data: nil, width: Int(imageSize.width), height: Int(imageSize.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue) else{
                    print("处理自定义背景图失败")
                    return false
                }
                
                ctx.concatenate(transform)
                let newRect = CGRect(x: 0, y: 0, width: imageSize.height, height: imageSize.width)
                ctx.draw(image.cgImage!, in: newRect)
                
                let cgImg = ctx.makeImage()!
                let newImg = UIImage(cgImage: cgImg)
                
                custom.bgImg = UIImageJPEGRepresentation(newImg, 1)
            }else{                
                custom.bgImg = UIImageJPEGRepresentation(image, 1)
            }
            
            return commit()
        }
        DataHandler.localCustom = nil
    }
    
    ///@param0: 是否为颜色 @param1: 是否为默认 @param2:下标 @param3:自定义颜色 @param4:自定义图片
    public func getCustomColorOrImage(closure: (_ isColor: Bool, _ isDefault: Bool, _ index: Int, _ color: UIColor?, _ color1: UIColor?, _ image: UIImage?)->()) {
        guard let custom = getCustom() else{
            closure(true, false, 0, nil, nil, nil)
            return
        }
        
        let r = custom.r
        let g = custom.g
        let b = custom.b
        let a = custom.a
        
        let r1 = custom.r1
        let g1 = custom.g1
        let b1 = custom.b1
        let a1 = custom.a1

        let isImage = custom.isImage
        let color = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
        let color1 = UIColor(red: CGFloat(r1), green: CGFloat(g1), blue: CGFloat(b1), alpha: CGFloat(a1))
        var image: UIImage?
        if let data = custom.bgImg{
            image = UIImage.init(data: data)
        }
        closure(isImage, custom.isCustom, Int(custom.index), isImage ? nil : color, isImage ? nil : color1, isImage ? image : nil)
    }
}
