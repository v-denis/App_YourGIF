//
//  GifCell.swift
//  App_yourGif
//
//  Created by MacBook Air on 03.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit
import Gifu

class GifCell: UICollectionViewCell {
    
	static let reuseId = String(describing: GifCell.self)
	var gifStringUrl: String? {
		didSet {
			gifImageView.reloadInputViews()
			gifImageView.stopAnimating()
			guard let urlString = gifStringUrl else { return }
			gifImageView.loadGifAndStartAnimating(usingUrlString: urlString)
		}
	}
	let gifImageView: CustomGIFImageView = {
		let giv = CustomGIFImageView(frame: .zero)
		giv.translatesAutoresizingMaskIntoConstraints = false
		giv.contentMode = .scaleAspectFit
		giv.clipsToBounds = true
		giv.layer.masksToBounds = true
		giv.layer.cornerRadius = 12
		return giv
	}()
	let activityIndicator: UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(style: .medium)
		ai.tintColor = .lightGray
		ai.hidesWhenStopped = true
		return ai
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		gifImageView.stopAnimating()
		gifImageView.prepareForReuse()
		gifImageView.image = nil
	}
	
	override func setNeedsLayout() {
		setupLayout()
	}
	
	private func setupLayout() {
		layer.borderColor = UIColor.lightGray.cgColor
		layer.cornerRadius = 12
		layer.borderWidth = 2
		addSubview(gifImageView)
		
//		activityIndicator.center = center
//		addSubview(activityIndicator)
		
		NSLayoutConstraint.activate([
			gifImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			gifImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			gifImageView.widthAnchor.constraint(equalTo: widthAnchor),
			gifImageView.heightAnchor.constraint(equalTo: heightAnchor)
		])
	}
	
	
}
