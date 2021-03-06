//
//  ViewController.swift
//  App_yourGif
//
//  Created by MacBook Air on 03.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
	
	private let emptyResultView = EmptyResultView(frame: .zero)
	private let networkService = NetworkService()
	private var gifData: GifData? {
		didSet {
			DispatchQueue.main.async {
				self.resultCollectionView.reloadData()
				self.showEmptyResultView(ofGifData: self.gifData)
			}
		}
	}
	private var downsizedGifStringUrls: [String] {
		return gifData?.data?.compactMap { $0.downsizedGifUrlString } ?? [String]()
	}
	private var originalGifStringUrls: [String] {
		return gifData?.data?.compactMap { $0.originalGifUrlString } ?? [String]()
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
	private var lastInsets: UIEdgeInsets = UIEdgeInsets()
	private var cellInsets: UIEdgeInsets {
		if UIDevice.current.orientation == .portrait {
			lastInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
			return lastInsets
		} else if UIDevice.current.orientation == .unknown {
			return lastInsets
		} else {
			lastInsets = UIEdgeInsets(top: 32, left: 64, bottom: 32, right: 64)
			return lastInsets
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
	private lazy var problemAlertView: AlertView = {
		let viewFrame = CGRect(x: 0, y: 45, width: view.frame.width, height: 45)
		let bcv = AlertView(frame: viewFrame, type: .badConnection)
		return bcv
	}()
	private lazy var activityIndicator: UIActivityIndicatorView = {
		let ai = UIActivityIndicatorView(style: .medium)
		ai.color = UIColor(named: "whiteBlackColor")
		ai.hidesWhenStopped = true
		ai.translatesAutoresizingMaskIntoConstraints = false
		return ai
	}()
	private var isSearchProblemExist: Bool = false {
		didSet {
			if isSearchProblemExist {
				problemAlertView.isHidden = false
			} else {
				problemAlertView.isHidden = true
			}
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configuratingElements()
		setupNavigationBarAndSearchBar()
		setupTapGesture()
		setupLayout()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if downsizedGifStringUrls.isEmpty {
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
			self.problemAlertView.frame = CGRect(x: 0, y: 45, width: self.view.frame.width, height: 45)
		}) { (_) in
			
		}
		
	}
	
	override var inputAccessoryView: UIView? {
		return problemAlertView
		
	}

	//To show inputAccessoryView
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	//Checking retain cycle
	deinit {
		print("Search View Controller deinited")
	}

}

//MARK: - SearchViewController subviews layout and items configuration
extension SearchViewController {
	
	private func setupLayout() {
		view.backgroundColor = .black
		view.tintColor = .white
		view.addSubview(resultCollectionView)
		emptyResultView.translatesAutoresizingMaskIntoConstraints = false
		resultCollectionView.addSubview(emptyResultView)
		searchController.searchBar.searchTextField.addSubview(activityIndicator)
		
		NSLayoutConstraint.activate([
			resultCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			resultCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		
		NSLayoutConstraint.activate([
			emptyResultView.centerXAnchor.constraint(equalTo: resultCollectionView.centerXAnchor),
			emptyResultView.topAnchor.constraint(equalTo: resultCollectionView.topAnchor, constant: 32),
			emptyResultView.widthAnchor.constraint(equalTo: resultCollectionView.widthAnchor, multiplier: 0.3),
			emptyResultView.heightAnchor.constraint(equalTo: emptyResultView.widthAnchor)
		])
		
		NSLayoutConstraint.activate([
			activityIndicator.trailingAnchor.constraint(equalTo: searchController.searchBar.searchTextField.trailingAnchor, constant: -28),
			activityIndicator.centerYAnchor.constraint(equalTo: searchController.searchBar.searchTextField.centerYAnchor)
		])
		
		resultCollectionView.keyboardDismissMode = .onDrag
		searchController.isActive = false
		setupSideAnchorsFor(orientation: UIDevice.current.orientation)
	}
	
	private func configuratingElements() {
		networkService.delegate = self
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
	
	private func searchBarFinishEditingAndChangeTitle(for searchText: String?) {
		guard let text = searchText, !text.isEmpty else { return }
		navigationItem.title = text
		searchController.searchBar.endEditing(true)
		searchController.isActive = false
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
		searchController.searchBar.searchTextField.placeholder = "search GIF's"
		searchController.searchBar.searchTextField.inputAccessoryView = problemAlertView
		searchController.searchBar.searchTextField.delegate = self
		
		navigationItem.searchController = searchController
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: nil)
		navigationController?.navigationBar.shadowImage = UIImage()
		configureNavigationBar(largeTitleColor: UIColor(named: "alwaysWhite")!, backgoundColor: #colorLiteral(red: 0.1406435422, green: 0.01249524726, blue: 0.4902973561, alpha: 1), tintColor: UIColor(named: "alwaysWhite")!, title: defaultSearchPhrase, preferredLargeTitle: true)
	}
	
	private func showEmptyResultView(ofGifData gifData: GifData?) {
		guard gifData != nil else { return }
		if let dataItems = gifData!.data {
			emptyResultView.isHidden = (dataItems.count == 0) ? false : true
		}
		
	}
}


//MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return downsizedGifStringUrls.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCell.reuseId, for: indexPath) as! GifCell
		let cellUrlString = downsizedGifStringUrls[indexPath.row]
		cell.gifStringUrl = cellUrlString
		return cell
	}
	

}


//MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let destVC = SingleGifViewController()
		let selectedUrlString = originalGifStringUrls[indexPath.row]
		destVC.gifUrlString = selectedUrlString
		if searchController.searchBar.isFirstResponder {
			searchController.searchBar.endEditing(true)
		}
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
		isSearchProblemExist = false
		activityIndicator.startAnimating()
		networkService.searchGifs(withPhrase: text) { (fetchedGifData) in
			DispatchQueue.main.async {
				self.activityIndicator.stopAnimating()
			}
			self.gifData = fetchedGifData
		}
	}
	
}


//MARK: - UISearchBarDelegate & UITextFieldDelegate
extension SearchViewController: UISearchBarDelegate, UITextFieldDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBarFinishEditingAndChangeTitle(for: searchBar.text)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard !searchText.isEmpty else {
			showDefaultResults()
			return
		}
		gifData = nil
		navigationItem.title = searchText
		fetchGifs(withSearchText: searchText)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		if navigationItem.title != defaultSearchPhrase {
			showDefaultResults()
		}
		searchBar.searchTextField.resignFirstResponder()
		becomeFirstResponder()
		searchController.isActive = false
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return !isSearchProblemExist
	}
	
	private func showDefaultResults() {
		gifData = nil
		fetchGifs(withSearchText: defaultSearchPhrase)
		searchController.searchBar.text = ""
		navigationItem.title = defaultSearchPhrase
	}
	
	
	
}

//MARK: - UITapGesture
extension SearchViewController {
	
	private func setupTapGesture() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
		tapGesture.numberOfTapsRequired = 2
		resultCollectionView.addGestureRecognizer(tapGesture)
	}
	
	@objc func tapGestureHandler(_ sender: UITapGestureRecognizer) {
		guard searchController.isActive else { return }
		guard searchController.searchBar.text != "" else {
			searchController.searchBar.endEditing(true)
			searchController.isActive = false
			return
		}
		searchBarFinishEditingAndChangeTitle(for: searchController.searchBar.text)
	}
	
}

//MARK: - HandleNetworkErrorsDelegate
extension SearchViewController: HandleNetworkErrorsDelegate {
	
	func showIncorrectRequestAlert() {
		DispatchQueue.main.async {
			self.showAlert(withType: .incorrectRequest)
		}
	}
	
	func showNoInternetAlert() {
		DispatchQueue.main.async {
			self.showAlert(withType: .noInternet)
		}
	}
	
	func showBadConnectionAlert() {
		DispatchQueue.main.async {
			self.showAlert(withType: .badConnection)
		}
	}
	
	private func showAlert(withType type: AlertType) {
		problemAlertView.viewType = type
		self.isSearchProblemExist = true
		problemAlertView.frame = CGRect(x: 0, y: 45, width: self.view.frame.width, height: 45)
		UIView.animate(withDuration: 0.5) {
			self.problemAlertView.frame.origin.y -= 45
		}
		
	}
	

	
}

/*
1. API giphy.com или любое на выбор.
2. На первом экране поле ввода поискового запроса и результаты поиска (анимированные изображения списком)
3. По умолчанию выводятся результаты поиска для запроса-примера. Например, результаты для запроса “Котики“.
4. Эти результаты отображаются если поисковый запрос удален.
5. По нажатию на изображение переходим на экран с GIF в полном размере.
*/
