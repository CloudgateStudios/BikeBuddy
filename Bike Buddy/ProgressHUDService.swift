//
//  ProgressHUDService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/20/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import SVProgressHUD
import BikeBuddyKit

public class ProgressHUDService {
    
    private let maskType = SVProgressHUDMaskType.gradient
    private let statusMessage = StringsService.getStringFor(key: "MapLoadingPopupMessage")
    
    /**
     The shared instanace that should be used to access all members of the service.
     */
    public class var sharedInstance: ProgressHUDService {
        struct Static {
            static let instance: ProgressHUDService = ProgressHUDService()
        }
        return Static.instance
    }
    
    /**
     Should not be used. Call ProgressHUDService.sharedInstance instead.**
     */
    private init() {
        SVProgressHUD.setDefaultMaskType(self.maskType)
    }
    
    /**
     Used to show the full screen popup. Will completely block the UI for the user.
     */
    func showHUD() {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show(withStatus: self.statusMessage)
        }
    }
    
    /**
     Dismiss the full screen popup from the screen. This must be called in order to return control back to the user.
     */
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
}
