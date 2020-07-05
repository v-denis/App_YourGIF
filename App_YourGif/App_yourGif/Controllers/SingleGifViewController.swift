//
//  SingleGifViewController.swift
//  App_yourGif
//
//  Created by MacBook Air on 03.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit
import Gifu

class SingleGifViewController: UIViewController {

	private let networkService = NetworkService()
	private let gifImageView: GIFImageView = {
		let giv = GIFImageView()
		giv.translatesAutoresizingMaskIntoConstraints = false
		giv.contentMode = .scaleAspectFit
		giv.clipsToBounds = true
		giv.layer.cornerRadius = 12
		giv.layer.masksToBounds = true
		return giv
	}()
	var gifName: String?
	var gifData: Data? {
		didSet {
			guard gifData != nil else { return }
			DispatchQueue.main.async {
				self.activityIndicator.stopAnimating()
				self.gifImageView.animate(withGIFData: self.gifData!)
			}
		}
	}
	var gifUrlString: String? {
		didSet {
			guard gifUrlString != nil else { return }
			activityIndicator.startAnimating()
			networkService.fetchGifData(fromUrlString: gifUrlString!) { (gifData) in
				self.gifData = gifData
			}
		}
	}
	let activityIndicator: UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(style: .large)
		ai.tintColor = .white
		ai.color = .white
		ai.translatesAutoresizingMaskIntoConstraints = false
		ai.hidesWhenStopped = true
		return ai
	}()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupLayout()
    }
    
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: { (_) in
			self.view.layoutIfNeeded()
		})
		
	}
	
	private func setupLayout() {
		navigationItem.largeTitleDisplayMode = .never
		
		view.backgroundColor = .black
		view.addSubview(gifImageView)
		gifImageView.addSubview(activityIndicator)
		
		NSLayoutConstraint.activate([
			gifImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			gifImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			gifImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			gifImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			activityIndicator.centerXAnchor.constraint(equalTo: gifImageView.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: gifImageView.centerYAnchor),
		])
	}
	
	
	deinit {
		print("SingleGifViewController: deinited")
	}

}
