//
//  VCLoggingViewController.swift
//  Lesson9_Concentration
//
//  Created by MacBook Air on 06.05.2020.
//  Copyright © 2020 Denis Valshchikov. All rights reserved.
//

import UIKit

class VCLoggingViewController: UIViewController {
	
	private struct LogGlobals {
		var prefix = ""
		var instanceCounts = [String:Int]()
		var lastLogTime = Date()
		var indentationInterval: TimeInterval = 1
		var indentationString = "__"
	}
	
	private static var logGlobals = LogGlobals()
	
	private static func logPrefix(for loggingName: String) -> String {
		if logGlobals.lastLogTime.timeIntervalSinceNow < -logGlobals.indentationInterval {
			logGlobals.prefix += logGlobals.indentationString
			print("")
		}
		logGlobals.lastLogTime = Date()
		return logGlobals.prefix + loggingName
	}

	private static func bumpInstanceCount(for loggingName: String) -> Int {
		logGlobals.instanceCounts[loggingName] = (logGlobals.instanceCounts[loggingName] ?? 0) + 1
		return logGlobals.instanceCounts[loggingName]!
	}
	
	private var instanceCount: Int!
	
	var vclLoggingName: String {
		return String(describing: type(of: self))
	}
	
	private func logVCL(_ msg: String) {
		if instanceCount == nil {
			instanceCount = VCLoggingViewController.bumpInstanceCount(for: vclLoggingName)
		}
		print("\(VCLoggingViewController.logPrefix(for: vclLoggingName))(\(instanceCount!)) \(msg)")
	}
	
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		logVCL("init(nibName:bundle:) - create in code")
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		logVCL("init(coder:) created via InterfaceBuilder")
	}
	
	deinit {
		logVCL("left the heap")
	}
	
	override func awakeFromNib() {
		logVCL("awakeFromNib()")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		logVCL("viewDidLoad()")
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		logVCL("viewWillAppear(animated = \(animated))")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		logVCL("viewDidAppear(animated = \(animated))")
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		logVCL("viewWillDisappear(animated = \(animated))")
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		logVCL("viewDidDisappear(animated = \(animated))")
	}
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		logVCL("didReceiveMemoryWarning()")
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		logVCL("viewWillLayoutSubviews() bounds.size = \(view.bounds.size)")
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		logVCL("viewDidLayoutSubviews() bounds.size = \(view.bounds.size)")
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		logVCL("viewWillTransition(to: \(size), with: \(coordinator)")
		coordinator.animate(alongsideTransition: { (context) in
			self.logVCL("begin animate(alongsideTransition:completion:)")
		}) { (context) -> Void in
			self.logVCL("end animate(alongsideTransition:completion:)")
		}
	}

}
