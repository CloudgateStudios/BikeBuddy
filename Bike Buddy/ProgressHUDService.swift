//
//  ProgressHUDService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/20/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import BikeBuddyKit

/// Modern wrapper around ProgressHUD for backward compatibility
@MainActor
public class ProgressHUDService {
    
    /**
     The shared instance that should be used to access all members of the service.
     */
    public static let sharedInstance = ProgressHUDService()
    
    /**
     Should not be used. Call ProgressHUDService.sharedInstance instead.
     */
    private init() {
        // No setup needed for modern implementation
    }
    
    /**
     Used to show the full screen popup. Will completely block the UI for the user.
     */
    public func showHUD(statusMessage: String) {
        ProgressHUD.show(withStatus: statusMessage)
    }
    
    /**
     Dismiss the full screen popup from the screen. This must be called in order to return control back to the user.
     */
    public func dismissHUD() {
        ProgressHUD.dismiss()
    }
}
