//
//  UIViewController + Extension.swift
//  App_yourGif
//
//  Created by MacBook Air on 05.07.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit


extension UIViewController {
	
	func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
		if #available(iOS 13.0, *) {
			let navBarAppearance = UINavigationBarAppearance()
			navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
			navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
			navBarAppearance.backgroundColor = backgoundColor
			
			navigationController?.navigationBar.standardAppearance = navBarAppearance
			navigationController?.navigationBar.compactAppearance = navBarAppearance
			navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
			
			navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
			navigationController?.navigationBar.isTranslucent = false
			navigationController?.navigationBar.tintColor = tintColor
			navigationItem.title = title
			navigationItem.titleView?.tintColor = .white
			navigationItem.titleView?.backgroundColor = .white
			
		} else {
			// Fallback on earlier versions
			navigationController?.navigationBar.barTintColor = backgoundColor
			navigationController?.navigationBar.tintColor = tintColor
			navigationController?.navigationBar.isTranslucent = false
			navigationItem.title = title
		}
	}
	
}
