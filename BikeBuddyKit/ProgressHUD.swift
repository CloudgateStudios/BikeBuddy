//
//  ProgressHUD.swift
//  Bike Buddy
//
//  Created by migration on 2/13/26.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import UIKit

/// Modern replacement for SVProgressHUD using native UIKit
@MainActor
public class ProgressHUD {
    
    // MARK: - Singleton
    
    static let shared = ProgressHUD()
    private init() {}
    
    // MARK: - Properties
    
    private var containerView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    private var messageLabel: UILabel?
    
    /// Optional window to use for presentation. If nil, will attempt to find key window (only available in main app).
    public static var presentationWindow: UIWindow?
    
    // MARK: - Public Methods
    
    public static func show() {
        shared.showProgress(message: nil)
    }
    
    public static func show(withStatus status: String?) {
        shared.showProgress(message: status)
    }
    
    public static func dismiss() {
        shared.hideProgress()
    }
    
    public static func showSuccess(withStatus status: String? = nil) {
        shared.showMessage(status, image: UIImage(systemName: "checkmark.circle.fill"), color: .systemGreen)
    }
    
    public static func showError(withStatus status: String? = nil) {
        shared.showMessage(status, image: UIImage(systemName: "xmark.circle.fill"), color: .systemRed)
    }
    
    public static func showInfo(withStatus status: String? = nil) {
        shared.showMessage(status, image: UIImage(systemName: "info.circle.fill"), color: .systemBlue)
    }
    
    // MARK: - Private Methods
    
    private func getKeyWindow() -> UIWindow? {
        // Use explicitly set window if available
        if let window = Self.presentationWindow {
            return window
        }
        
        // Try to get the key window using value(forKey:) approach
        // This works at runtime and avoids compile-time checks
        return findKeyWindowFromApplication()
    }
    
    private func findKeyWindowFromApplication() -> UIWindow? {
        // UIApplication is not available in extensions; NSClassFromString returns nil there.
        guard NSClassFromString("UIApplication") != nil else { return nil }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    private func showProgress(message: String?) {
        guard let keyWindow = getKeyWindow() else {
            return
        }
        
        // Remove existing if any
        hideProgress()
        
        // Create container
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.frame = keyWindow.bounds
        container.alpha = 0
        
        // Create blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        
        // Create activity indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        
        // Create label if needed
        var label: UILabel?
        if let message = message {
            let lbl = UILabel()
            lbl.text = message
            lbl.font = .preferredFont(forTextStyle: .subheadline)
            lbl.textColor = .label
            lbl.textAlignment = .center
            lbl.numberOfLines = 0
            lbl.translatesAutoresizingMaskIntoConstraints = false
            label = lbl
        }
        
        // Build hierarchy
        container.addSubview(blurView)
        blurView.contentView.addSubview(indicator)
        
        var constraints: [NSLayoutConstraint] = [
            blurView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            blurView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            blurView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            indicator.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24)
        ]
        
        if let label = label {
            blurView.contentView.addSubview(label)
            constraints.append(contentsOf: [
                label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16),
                label.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24)
            ])
        } else {
            constraints.append(indicator.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24))
        }
        
        NSLayoutConstraint.activate(constraints)
        
        keyWindow.addSubview(container)
        
        self.containerView = container
        self.activityIndicator = indicator
        self.messageLabel = label
        
        UIView.animate(withDuration: 0.2) {
            container.alpha = 1
        }
    }
    
    private func showMessage(_ message: String?, image: UIImage?, color: UIColor) {
        guard let keyWindow = getKeyWindow() else {
            return
        }
        
        hideProgress()
        
        // Create container
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.frame = keyWindow.bounds
        container.alpha = 0
        
        // Create blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        
        // Create image view
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.contentView.addSubview(imageView)
        
        var constraints: [NSLayoutConstraint] = [
            blurView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            blurView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            blurView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            imageView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        if let message = message {
            let label = UILabel()
            label.text = message
            label.font = .preferredFont(forTextStyle: .subheadline)
            label.textColor = .label
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            
            blurView.contentView.addSubview(label)
            constraints.append(contentsOf: [
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
                label.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24)
            ])
        } else {
            constraints.append(imageView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24))
        }
        
        NSLayoutConstraint.activate(constraints)
        
        container.addSubview(blurView)
        keyWindow.addSubview(container)
        
        self.containerView = container
        
        UIView.animate(withDuration: 0.2) {
            container.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hideProgress()
            }
        }
    }
    
    private func hideProgress() {
        guard let container = containerView else { return }
        
        UIView.animate(withDuration: 0.2) {
            container.alpha = 0
        } completion: { _ in
            container.removeFromSuperview()
            self.containerView = nil
            self.activityIndicator = nil
            self.messageLabel = nil
        }
    }
}
