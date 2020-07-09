//
//  NetworkService.swift
//  App_yourGif
//
//  Created by MacBook Air on 04.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import Foundation

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
}

class NetworkService {
	
	private let apiKey = "YFsBAOyyd4PtFMtBoy3ajbyaDDWI9r74"
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
		var searchPhrase = phrase
		if phrase.contains(" ") {
			searchPhrase = phrase.split(separator: " ").joined(separator: "+")
		}
		let language = determinePhraseLanguage(phrase: searchPhrase)
		guard language != Language.unknown else { return nil }
		let resultUrlString = baseUrlString + "&q=\(searchPhrase)" + "&lang=\(language)"
		guard let urlAllowedString = resultUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
		return URL(string: urlAllowedString)
	}
	
	private func determinePhraseLanguage(phrase: String) -> Language {
		for scalar in phrase.unicodeScalars {
			switch scalar.value {
				case 65...90, 97...122: return Language.en
				case 1072...1103, 1040...1071: return Language.ru
				default: continue
			}
		}
		return Language.unknown
	}
	
	
}
