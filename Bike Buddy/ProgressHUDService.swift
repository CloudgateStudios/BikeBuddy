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
    class var sharedInstance: ProgressHUDService {
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
     
        - parameter message: The string that should be used in the popup. If no value is given a default value of MapLoadingPopupMessage will be used.
    */
    func showHUD(message: String = self.statusMessage) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.showWithStatus(message)
        }
    }

    /**
        Dismiss the full screen popup from the screen. This must be called in order to return control back to the user.
    */
    func dismissHUD() {
        SVProgressHUD.dismiss()
    }
}
