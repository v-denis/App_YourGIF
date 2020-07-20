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
	var viewControllerTitle: String?
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
	lazy var shareBatButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(handleShareButtonTapped(_:)))
	
	
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
		
		let imageV = UIImageView()
		imageV.startAnimating()
		
		shareBatButtonItem.tintColor = .white
		navigationItem.rightBarButtonItem = shareBatButtonItem
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
	
	
	@objc func handleShareButtonTapped(_ sender: UIBarButtonItem) {
		
		guard let shareGifData = gifData else { return }
		
		if let source = CGImageSourceCreateWithData(shareGifData as CFData, nil) {
			
			guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return }
			let baseImage = UIImage(cgImage: cgImage)
			let activityVC = UIActivityViewController(activityItems: [baseImage as Any], applicationActivities: nil)
			activityVC.popoverPresentationController?.sourceView = self.view
			self.present(activityVC, animated: true)
			
		} else {
			let activityVC = UIActivityViewController(activityItems: [shareGifData as Any], applicationActivities: nil)
			
			activityVC.popoverPresentationController?.sourceView = self.view
			self.present(activityVC, animated: true)
		}
	}
	
	deinit {
		print("SingleGifViewController: deinited")
	}

}
