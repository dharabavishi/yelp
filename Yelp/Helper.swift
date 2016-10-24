//
//  Helper.swift
//  Yelp
//
//  Created by Ruchit Mehta on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD
class Helper: NSObject {
    
    static func showHud(viewController:UIViewController){
        MBProgressHUD.showAdded(to: viewController.view, animated: true)
    }
    static func hideHud (viewController:UIViewController){
        MBProgressHUD.hide(for: viewController.view, animated: true)
    }

}
