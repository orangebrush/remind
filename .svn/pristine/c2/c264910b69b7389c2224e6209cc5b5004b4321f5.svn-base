//
//  ViewController.swift
//  RemindTest
//
//  Created by gg on 05/12/2017.
//  Copyright © 2017 ganyi. All rights reserved.
//

import UIKit
import RemindData
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    private func config(){
    }
    
    @IBAction func click(_ sender: Any){
//        let dataManager = DataManager.share()
    }
}

extension DispatchQueue{
    private static var _onceTracker = [String]()
    
    public class func once(token: String, closure: ()->()){
        objc_sync_enter(self)
        
        defer {
            objc_sync_exit(self)
        }
        
        if _onceTracker.contains(token){
            return
        }
        
        _onceTracker.append(token)
        closure()
    }
}

extension UIViewController{
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let leftBarBtn = UIBarButtonItem(title: "", style: .plain, target: self,
//                                         action: #selector(backToPrevious))
//        leftBarBtn.image = UIImage(named: "back")
//
//        //用于消除左边空隙，要不然按钮顶不到最前面
//        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
//                                     action: nil)
//        spacer.width = -10
//
//        self.navigationItem.leftBarButtonItems = [spacer, leftBarBtn]
//    }
//
//    //返回按钮点击响应
//    @objc func backToPrevious(){
//        self.navigationController!.popViewController(animated: true)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        let leftBarBtn = UIBarButtonItem(title: "s", style: .plain, target: self, action: #selector(backToPrevious))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = -10
        navigationItem.leftBarButtonItems = [spacer, leftBarBtn]
    }
    
    @objc func backToPrevious(){
        navigationController?.popViewController(animated: true)
    }
}

/*
extension UINavigationItem{
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        swizing()
    }
    
    //交换方法（修改返回按钮）
    func swizing(){
        
        DispatchQueue.once(token: "back") {
            let originalMethod = class_getInstanceMethod(UINavigationItem.self, #selector(getter: backBarButtonItem))
            let destMethod = class_getInstanceMethod(UINavigationItem.self, #selector(myCustomBackButton))
            method_exchangeImplementations(originalMethod!, destMethod!)
        }
    }
    
    static var kCustomBackButtonKey = 0
    @objc func myCustomBackButton() -> UIBarButtonItem? {
        var item = self.myCustomBackButton()
        if item == nil{
            item = objc_getAssociatedObject(self, &UINavigationItem.kCustomBackButtonKey) as? UIBarButtonItem
            if item == nil{
//                item = UIBarButtonItem(image: UIImage(), style: UIBarButtonItemStyle.done, target: nil, action: nil)
                item = UIBarButtonItem(title: "test", style: .done, target: nil, action: nil)
                objc_setAssociatedObject(self, &UINavigationItem.kCustomBackButtonKey, item, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }else{
                return item
            }
        }
        return item
    }
}
*/
