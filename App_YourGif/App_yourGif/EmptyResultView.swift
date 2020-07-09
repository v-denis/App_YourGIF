//
//  EmptyResultView.swift
//  App_yourGif
//
//  Created by MacBook Air on 09.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit

class EmptyResultView: UIView {

	let emptyImageView: UIImageView = {
		let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFit
		iv.image = UIImage(named: "noresult")?.withRenderingMode(.alwaysTemplate)
		iv.tintColor = .lightGray
		
		return iv
	}()
	let noresultLabel: UILabel = {
		let label = UILabel()
		label.text = "No search results"
		label.textColor = .lightGray
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	
	override init(frame: CGRect) {
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
		addSubview(noresultLabel)
		addSubview(emptyImageView)
		
		NSLayoutConstraint.activate([
			emptyImageView.topAnchor.constraint(equalTo: topAnchor),
			emptyImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			emptyImageView.widthAnchor.constraint(equalTo: widthAnchor),
			emptyImageView.bottomAnchor.constraint(equalTo: noresultLabel.topAnchor, constant: -16),
			noresultLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
			noresultLabel.heightAnchor.constraint(equalToConstant: 25),
			noresultLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}

}
