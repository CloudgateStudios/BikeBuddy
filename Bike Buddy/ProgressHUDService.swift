//
//  ProgressHUDService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/5/15.
//  Copyright © 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import SVProgressHUD

class ProgressHUDService {
    
    private let maskType = SVProgressHUDMaskType.Gradient
    private let statusMessage = NSLocalizedString("MapLoadingPopupMessage", comment: "")
    
    /**
     The shared instanace that should be used to access all members of the service.
     */
    class var sharedInstance : ProgressHUDService {
        struct Static {
            static let instance : ProgressHUDService = ProgressHUDService()
        }
        return Static.instance
    }
    
    /**
     **Should not be used. Call StationsDataService.sharedInstance instead.**
     */
    private init(){
        SVProgressHUD.setDefaultMaskType(self.maskType)
    }
    
    func showHUD() {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.showWithStatus(self.statusMessage)
        }
    }
    
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
}