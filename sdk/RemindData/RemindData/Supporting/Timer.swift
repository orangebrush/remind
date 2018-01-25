//
//  Timer.swift
//  RemindData
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import Foundation
public typealias TimeTask = (_ cancel: Bool)->()
public func delay(_ time: TimeInterval, task: @escaping ()->()) -> TimeTask?{
    func dispathLater(_ block: @escaping ()->()){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
    }
    
    var closure: (()->())? = task
    var result: TimeTask?
    
    let delayedClosure: TimeTask = {
        cancel in
        if let internalClosure = closure {
            if !cancel {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispathLater {
        if let delayedClosure = result{
            delayedClosure(false)
        }
    }
    
    return result
}

public func cancel(_ task: TimeTask?){
    task?(true)
}
