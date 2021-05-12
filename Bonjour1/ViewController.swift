//
//  ViewController.swift
//  Bonjour1
//
//  Created by Eric Kampman on 5/12/21.
//

import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		browser.browse()
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	let browser = Browser()
}

extension ViewController: BrowserDelegate {
	func needsUpdate() {
		view.needsDisplay = true
	}
}

