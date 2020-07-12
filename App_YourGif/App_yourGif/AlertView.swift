//
//  BadConnectionView.swift
//  App_yourGif
//
//  Created by MacBook Air on 09.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit

enum AlertType: String {
	case badConnection = "Bad internet connection"
	case noInternet = "No internet connection"
	case incorrectRequest = "Invalid search request"
}

class AlertView: UIView {

	private let problemLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.backgroundColor = .systemRed
		label.font = .preferredFont(forTextStyle: .headline)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	var viewType: AlertType {
		didSet {
			setupLabel(forType: viewType)
		}
	}
	
	init(frame: CGRect, type: AlertType) {
		self.viewType = type
		problemLabel.text = type.rawValue
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
	
	private func setupLabel(forType type: AlertType) {
		switch type {
			case .badConnection:
				problemLabel.text = viewType.rawValue
				problemLabel.backgroundColor = .systemRed
			case .noInternet:
				problemLabel.text = viewType.rawValue
				problemLabel.backgroundColor = .systemRed
			case .incorrectRequest:
				problemLabel.text = viewType.rawValue
				problemLabel.backgroundColor = #colorLiteral(red: 0.698524102, green: 0.6536487615, blue: 0.02305808367, alpha: 1)
		}
	}
	
	private func setupLayout() {
		addSubview(problemLabel)
		
		NSLayoutConstraint.activate([
			problemLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			problemLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			problemLabel.widthAnchor.constraint(equalTo: widthAnchor),
			problemLabel.heightAnchor.constraint(equalTo: heightAnchor)
		])
	}
	
}
