//
//  ViewController.swift
//  App_yourGif
//
//  Created by MacBook Air on 03.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
	
	private let networkService = NetworkService()
	private var gifStringUrls = [String]() {
		didSet {
			DispatchQueue.main.async {
				self.resultCollectionView.reloadData()
			}
		}
	}
	private let defaultSearchPhrase = "Cats"
	private let searchController = UISearchController(searchResultsController: nil)
	private lazy var resultCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.register(GifCell.self, forCellWithReuseIdentifier: GifCell.reuseId)
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.dataSource = self
		cv.delegate = self
		return cv
	}()
	private var cellInsets: UIEdgeInsets {
		if UIDevice.current.orientation == .landscapeLeft ||
			UIDevice.current.orientation == .landscapeRight {
			return UIEdgeInsets(top: 32, left: 64, bottom: 32, right: 64)
		} else {
			return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		}
	}
	private lazy var portraitSideAnchors = [
		resultCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
		resultCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
	]
	private lazy var landscapeLeftSideAnchors = [
		resultCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
		resultCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
	]
	private lazy var landscapeRightSideAnchors = [
		resultCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
		resultCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
	]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .black
		view.tintColor = .white
		setupNavigationBarAndSearchBar()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupLayout()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if gifStringUrls.isEmpty {
			fetchGifs(withSearchText: defaultSearchPhrase)
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard resultCollectionView.superview != nil else { return }
		self.resultCollectionView.collectionViewLayout.invalidateLayout()
		self.setupSideAnchorsFor(orientation: UIDevice.current.orientation)
		coordinator.animate(alongsideTransition: { (_) in
			self.view.layoutIfNeeded()
		})
		
	}

}

//MARK: - SearchViewController subviews layout and configuration
extension SearchViewController {
	
	private func setupLayout() {
		view.addSubview(resultCollectionView)
		
		NSLayoutConstraint.activate([
			resultCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			resultCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		setupSideAnchorsFor(orientation: UIDevice.current.orientation)
	}
	
	
	private func setupSideAnchorsFor(orientation: UIDeviceOrientation) {
		switch orientation {
			case .landscapeLeft:
				activateAnchors(landscapeLeftSideAnchors,
								andDeactivate: portraitSideAnchors + landscapeRightSideAnchors)
			case .landscapeRight:
				activateAnchors(landscapeRightSideAnchors,
								andDeactivate: portraitSideAnchors + landscapeRightSideAnchors)
			default:
				activateAnchors(portraitSideAnchors,
								andDeactivate: landscapeRightSideAnchors + landscapeLeftSideAnchors)
		}
	}
	
	private func activateAnchors(_ activeAnchors: [NSLayoutConstraint], andDeactivate deactiveAnchors: [NSLayoutConstraint]) {
		deactiveAnchors.forEach { $0.isActive = false }
		activeAnchors.forEach { $0.isActive = true }
	}
	
	private func setupNavigationBarAndSearchBar() {
		
		navigationItem.hidesSearchBarWhenScrolling = false
		searchController.hidesNavigationBarDuringPresentation = true
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.delegate = self
		searchController.searchBar.tintColor = UIColor(named: "alwaysWhite")
		searchController.searchBar.searchTextField.textColor = UIColor(named: "alwaysWhite")
		searchController.searchBar.searchTextField.backgroundColor = UIColor(named: "textFieldColor") 
		searchController.searchBar.searchTextField.tintColor = .orange
		searchController.searchBar.searchTextField.tokenBackgroundColor = UIColor(named: "alwaysWhite")
		searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search GIF's", attributes: [.foregroundColor:UIColor.lightGray])
		searchController.searchBar.searchTextField.typingAttributes = [.foregroundColor:UIColor(named: "alwaysWhite")!]

		navigationItem.searchController = searchController
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: nil)

		navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1406435422, green: 0.01249524726, blue: 0.4902973561, alpha: 1)
		navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.1406435422, green: 0.01249524726, blue: 0.4902973561, alpha: 1)
		navigationController?.navigationBar.tintColor = UIColor(named: "alwaysWhite")
		navigationController?.navigationBar.barStyle = .black
		navigationController?.navigationBar.shadowImage = UIImage()

		navigationController?.navigationItem.titleView?.tintColor = UIColor(named: "alwaysWhite")
		navigationController?.navigationItem.titleView?.backgroundColor = UIColor(named: "alwaysWhite")
		
		configureNavigationBar(largeTitleColor: UIColor(named: "alwaysWhite")!, backgoundColor: #colorLiteral(red: 0.1406435422, green: 0.01249524726, blue: 0.4902973561, alpha: 1), tintColor: UIColor(named: "alwaysWhite")!, title: defaultSearchPhrase, preferredLargeTitle: true)
	}
	
}


//MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return gifStringUrls.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCell.reuseId, for: indexPath) as! GifCell
		let cellUrlString = gifStringUrls[indexPath.row]
		cell.gifStringUrl = cellUrlString
		return cell
	}
	

	
}


//MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let destVC = SingleGifViewController()
		let selectedUrlString = gifStringUrls[indexPath.row]
		destVC.gifUrlString = selectedUrlString
		navigationController?.pushViewController(destVC, animated: true)
	}
}


//MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let safeAreaOriginX = view.safeAreaLayoutGuide.layoutFrame.origin.x
		let cellWidth = (view.bounds.width - cellInsets.left * 2 - cellInsets.right * 2 - safeAreaOriginX) / 2
		let cellHeight = cellWidth
		return CGSize(width: cellWidth, height: cellHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return cellInsets
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
			return 64
		} else {
			return 32
		}
	}
}


//MARK: - Networking: fetching GIF's
extension SearchViewController {
	
	private func fetchGifs(withSearchText text: String) {
		networkService.searchGifs(withPhrase: text) { (gifData) in
			guard let fetchedGifData = gifData.data else { return }
			self.gifStringUrls = fetchedGifData.compactMap { $0.downsizedGifUrlString }
		}
	}
	
}


//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let inputText = searchBar.text, !inputText.isEmpty else { return }
		fetchGifs(withSearchText: inputText)
		searchBar.text = ""
		navigationItem.title = inputText
		searchController.isActive = false
		searchBar.endEditing(true)
	}
	
}


/*
1. API giphy.com или любое на выбор.
2. На первом экране поле ввода поискового запроса и результаты поиска (анимированные изображения списком)
3. По умолчанию выводятся результаты поиска для запроса-примера. Например, результаты для запроса “Котики“.
4. Эти результаты отображаются если поисковый запрос удален.
5. По нажатию на изображение переходим на экран с GIF в полном размере.
*/
