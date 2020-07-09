//
//  BadConnectionView.swift
//  App_yourGif
//
//  Created by MacBook Air on 09.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit

enum BadConnectionType: String {
	case badConnection = "Bad internet connection"
	case noInternet = "No internet connection"
}

class BadConnectionView: UIView {

	private let badInternetLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.backgroundColor = .systemRed
		label.font = .preferredFont(forTextStyle: .title3)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	var viewType: BadConnectionType {
		didSet {
			badInternetLabel.text = viewType.rawValue
		}
	}
	
	init(frame: CGRect, type: BadConnectionType) {
		self.viewType = type
		badInternetLabel.text = type.rawValue
		super.init(frame: frame)
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func setNeedsLayout() {
		super.setNeedsLayout()
		setupLayout()
	}
	
	private func setupLayout() {
		addSubview(badInternetLabel)
		
		NSLayoutConstraint.activate([
			badInternetLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			badInternetLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			badInternetLabel.widthAnchor.constraint(equalTo: widthAnchor),
			badInternetLabel.heightAnchor.constraint(equalTo: heightAnchor)
		])
	}
	
}
