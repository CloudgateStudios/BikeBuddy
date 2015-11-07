//
//  SettingsAboutViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class SettingsAboutViewController: UIViewController {

    //MARK: - View Outlets
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var webView: UIWebView!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStrings()
        
        loadAboutWebPage()
    }
    
    private func setupStrings() {
        navBarItem.title = NSLocalizedString("SettingsAboutNavBarTitle", comment: "")
    }
    
    private func loadAboutWebPage() {
        if let path = NSBundle.mainBundle().pathForResource("about", ofType: "html") {
            if let html = try? String.init(contentsOfFile: path, encoding: NSUTF8StringEncoding) {
                self.webView.loadHTMLString(html, baseURL: NSBundle.mainBundle().bundleURL)
            }
        }
    }
}
