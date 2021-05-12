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
		
		browser = Browser(delegate: self)
		browser.browse()
		startListening()
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	func startListening() {
		if let listener = gListener {
			// If your app is already listening, just update the name.
			// FIXME
		} else {
			// If your app is not yet listening, start a new listener.
			gListener = Listener()
		}

		if let listener = gListener {
			listener.listen()
		}
	}

	var browser: Browser!
	
	var name = "Default"
}

extension ViewController: BrowserDelegate, ConnectionDelegate {
	func needsUpdate() {
		view.needsDisplay = true
	}
}

