//
//  Gif.swift
//  App_yourGif
//
//  Created by MacBook Air on 03.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import Foundation

struct GifData: Decodable {
	var data: [GifDataItem]?
	var status: Int?
	var msg: String?
	
}

struct GifDataItem: Decodable {
	var images: GifImages?
	var type: String?
	var id: String?
	
	var originalGifUrlString: String? {
		return images?.original?.url
	}
	
	var downsizedGifUrlString: String? {
		return images?.downsized?.url
	}
}

struct GifImages: Decodable {
	var original: GifImagesData?
	var fixed_height_still: GifImagesData?
	var downsized: GifImagesData?
}


struct GifImagesData: Decodable {
	var url: String?
}
