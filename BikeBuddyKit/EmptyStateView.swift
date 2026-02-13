//
//  EmptyStateView.swift
//  Bike Buddy
//
//  Created by migration on 2/13/26.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import UIKit

/// Modern replacement for DZNEmptyDataSet using native UIKit
class EmptyStateView: UIView {
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Initialization
    
    init(image: UIImage? = nil, title: String, message: String? = nil) {
        super.init(frame: .zero)
        
        setupView()
        configure(image: image, title: title, message: message)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32)
        ])
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(image: UIImage?, title: String, message: String?) {
        imageView.image = image
        imageView.isHidden = (image == nil)
        
        titleLabel.text = title
        
        messageLabel.text = message
        messageLabel.isHidden = (message == nil || message?.isEmpty == true)
    }
}

// MARK: - UITableView Extension

public extension UITableView {
    
    /// Shows an empty state view as the background view of the table view
    func showEmptyState(image: UIImage? = nil, title: String, message: String? = nil) {
        let emptyView = EmptyStateView(image: image, title: title, message: message)
        emptyView.backgroundColor = .systemBackground
        backgroundView = emptyView
    }
    
    /// Removes the empty state view
    func hideEmptyState() {
        backgroundView = nil
    }
}
