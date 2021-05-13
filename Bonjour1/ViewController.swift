//
//  ViewController.swift
//  Bonjour1
//
//  Created by Eric Kampman on 5/12/21.
//

import Cocoa
import Network
import os

class ViewController: NSViewController, NSCollectionViewDataSource {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		browser = Browser(delegate: self)
		browser.browse()
		startListening()
		
		collectionView.dataSource = self
	}
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	func startListening() {
		if let listener = gListener {
			listener.resetName(name)
		} else {
			// If your app is not yet listening, start a new listener.
			gListener = Listener(name: name, delegate: self)
		}

		if let listener = gListener {
			listener.listen()
		}
	}
	
	func updateListening() {
		if let listener = gListener {
			// If your app is already listening, just update the name.
			listener.resetName(name)
		} else {
			// If your app is not yet listening, start a new listener.
			gListener = Listener(name: name, delegate: self)
		}
	}

	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		logger.debug("collectionView Count: \(self.browser.results.count)")
		return self.browser.results.count
	}

	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem
	{
		let item = self.collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NodeCollectionViewItem"), for: indexPath)
		
		let results = self.browser.results
		let path = indexPath as NSIndexPath
		let peerEndpoint = results[path.item].endpoint
		
		if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = peerEndpoint {
			item.textField?.stringValue = name
		}
		
		return item
	}

	@IBAction func nameFieldAction(_ sender: NSTextField) {
		name = sender.stringValue
		
		updateListening()	// this is not a great solution FIXME
	}
	@IBOutlet weak var nameField: NSTextField!
	
	@IBOutlet weak var collectionView: NSCollectionView!
	
	var browser: Browser!
	var name = "Default"
	
	let logger = Logger(subsystem: "com.unlikelyware.bonjour1", category: "ViewController")

}

extension ViewController: BrowserDelegate, ConnectionDelegate {
	func needsUpdate() {
		logger.debug("needsUpdate Count: \(self.browser.results.count)")
		
		view.needsDisplay = true
		self.collectionView.needsDisplay = true
		self.collectionView.reloadData()
	}
}

