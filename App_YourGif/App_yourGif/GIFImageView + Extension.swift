//
//  GIFImageView + Extension.swift
//  App_yourGif
//
//  Created by MacBook Air on 05.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit
import Gifu

class CustomGIFImageView: UIImageView, GIFAnimatable {
	
	public lazy var animator: Animator? = {
		return Animator(withDelegate: self)
	}()
	
	override public func display(_ layer: CALayer) {
		updateImageIfNeeded()
	}
	
	private var gifImageUrlString: String?
	private let gifCache: NSCache<NSString,NSData> = {
		let cache = NSCache<NSString,NSData>()
		cache.evictsObjectsWithDiscardedContent = false
		return cache
	}()
	private lazy var activityIndicator: UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(style: .medium)
		ai.tintColor = .white
		ai.color = .white
		ai.center = self.center
		ai.hidesWhenStopped = true
		return ai
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		activityIndicator.frame = bounds
		addSubview(activityIndicator)
	}
	
	
	func loadGifAndStartAnimating(usingUrlString urlString: String) {
		activityIndicator.startAnimating()
		gifImageUrlString = urlString
		if let gifData = gifCache.object(forKey: NSString(string: urlString)) {
			activityIndicator.stopAnimating()
			self.animate(withGIFData: gifData as Data)
		} else {
			guard let url = URL(string: urlString) else { return }
			URLSession.shared.dataTask(with: url) { (data, response, err) in
				if let error = err {
					print("loadGifAndStartAnimatingUsing: urlSessionError: ", error.localizedDescription)
					return
				}
				guard let gifData = data else { return }
				DispatchQueue.main.async {
					if self.gifImageUrlString == urlString {
						self.activityIndicator.stopAnimating()
						self.animate(withGIFData: gifData)
						self.gifCache.setObject(gifData as NSData, forKey: NSString(string: urlString))
					}
					
				}
			}.resume()
		}
		
	}
	
}





