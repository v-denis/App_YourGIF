//
//  NetworkService.swift
//  App_yourGif
//
//  Created by MacBook Air on 04.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import Foundation

enum GifLimit: Int {
	case low = 10
	case medium = 26
	case height = 50
	case maximum = 100
}

enum Language: String {
	case en
	case ru
	case unknown
}

enum SearchGifError: String {
	case badInternetConnection = "The request timed out."
	case noInternetConnection = "The Internet connection appears to be offline."
}

protocol HandleNetworkErrorsDelegate: class {
	func showBadConnectionAlert()
	func showNoInternetAlert()
	func showIncorrectRequestAlert()
}

class NetworkService {
	
	private let apiKey = "YFsBAOyyd4PtFMtBoy3ajbyaDDWI9r74"
	private let baseURL = "https://api.giphy.com/v1/gifs/search"
	private var baseUrlString: String {
		return "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&limit=24"
	}
	private var searchPhrase: String = ""
	weak var delegate: HandleNetworkErrorsDelegate?
	
	func searchGifs(withPhrase phrase: String, completion: @escaping (GifData) -> ()) {
		self.searchPhrase = phrase
		if let url = generateQuerySearchUrl(from: phrase) {
			URLSession.shared.dataTask(with: url) { (data, response, err) in
				
				if let error = err {
					switch error.localizedDescription {
						case SearchGifError.noInternetConnection.rawValue:
							self.delegate?.showNoInternetAlert()
						case SearchGifError.badInternetConnection.rawValue:
							self.delegate?.showBadConnectionAlert()
						default:
							print("NetworkService: searchGifs: URLSession uknwown error: ", error.localizedDescription)
					}
					return
				}
				
				guard let httpResponse = response as? HTTPURLResponse else { return }
				guard (200..<400).contains(httpResponse.statusCode) else { return }
				guard let jsonData = data else { return }
				
				do {
					let gifData = try JSONDecoder().decode(GifData.self, from: jsonData)
					if self.searchPhrase == phrase {
						completion(gifData)
					}
				} catch let jsonError {
					print("JSON decode error: ", jsonError.localizedDescription)
					//Error handling
				}
				
			}.resume()
		} else {
			delegate?.showIncorrectRequestAlert()
			print("searchGifs: url generating error")
			//Error handling
		}
	}
	
	func fetchGifData(fromUrlString urlString: String, completion: @escaping (Data) -> ()) {
		if let url = URL(string: urlString) {
			URLSession.shared.dataTask(with: url) { (data, response, err) in
				//Code duplication
				if let error = err {
					//Error handling
					print(error.localizedDescription)
					return
				}
				
				guard let httpResponse = response as? HTTPURLResponse else { return }
				guard (200..<400).contains(httpResponse.statusCode) else { return }
				guard let gifData = data else { return }
				completion(gifData)
			}.resume()
		} else {
			print("Error --> NetworkService: fetchGifData: Can't fetch gif data")
			//Error handling
		}
	}
	
	
	private func generateQuerySearchUrl(from phrase: String) -> URL? {
		//		CFStringTokenizerCopyBestStringLanguage(phrase as CFString, CFRange(location: 0, length: phrase.count))
		guard let resultURL = URL(string: baseURL) else { return nil }
		let language = determinePhraseLanguage(phrase: searchPhrase)
		guard language != Language.unknown else { return nil }
		var urlComponents = URLComponents(url: resultURL, resolvingAgainstBaseURL: false)
		urlComponents?.queryItems = [
			URLQueryItem(name: "api_key", value: apiKey),
			URLQueryItem(name: "q", value: phrase),
			URLQueryItem(name: "lang", value: language.rawValue),
			URLQueryItem(name: "limit", value: "\(GifLimit.medium.rawValue)")
			//Configure number of elements here!
		]
		guard let queryUrl = urlComponents?.url else { return nil }
		return queryUrl
	}
	
	private func determinePhraseLanguage(phrase: String) -> Language {
		for scalar in phrase.unicodeScalars {
			switch scalar.value {
				case 65...90, 97...122: return Language.en
				case 48...57: return Language.en //If numbers in phrase
				case 1072...1103, 1040...1071: return Language.ru
				default: continue
			}
		}
		return Language.unknown
	}
	
	
}
