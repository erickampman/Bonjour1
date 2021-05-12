//
//  Browser.swift
//  Bonjour1
//
//  Created by Eric Kampman on 5/12/21.
//

import Network
import Foundation
import os

class Browser: NSObject {
	
	override init() {
		super.init()
		
	}

	func browse() {
		let params = NWParameters()
		params.includePeerToPeer = true
		browser = NWBrowser(for: .bonjour(type: browserType, domain: browserDomain), using: params)
		
		browser.stateUpdateHandler = { state in
			
			switch (state) {
			case .setup: 			//The browser has been initialized but not started.
				self.logger.debug("Browser Initialized")
			case .ready: 			//The browser is registered for discovering services.
				self.logger.debug("Browser registered")
			case .failed(let error): //The browser has encountered a fatal error.
				switch error {
				case .posix(let perror):
					self.logger.error("Posix Error: \(error.debugDescription)")
				case .dns(let derror):
					self.logger.error("DNS Error: \(error.debugDescription)")
				case .tls(let perror):
					self.logger.error("TLS Error: \(error.debugDescription)")
				@unknown default:
					self.logger.error("Unknown Error: \(error.debugDescription)")
				}
			case .cancelled:			// The browser has been canceled.
				self.logger.debug("Browser Canceller")
			case .waiting(_):
				self.logger.debug("Browser Waiting")
			@unknown default:
				self.logger.debug("Browser Unknown State")
			}
		}
		
		browser.browseResultsChangedHandler = { results, changes in
			self.delegate?.needsUpdate()
		}

		// Start browsing and ask for updates on the main queue.
		browser.start(queue: .main)
	}
	
	func updateResults(results: Set<NWBrowser.Result>) {
		guard let delegate = delegate else { return }
		
		self.results = [NWBrowser.Result]()
		for result in results {
			if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint {
				if name != self.name {
					self.results.append(result)
				}
			}
		}
		delegate.needsUpdate()
	}
	
	var browser: NWBrowser!
	let browserType = "_bonjour1._tcp"
	let browserDomain = String?.none
	var name = "My Name"
	let delegate = BrowserDelegate?.none
	
	var results: [NWBrowser.Result] = [NWBrowser.Result]()
	
	let logger = Logger(subsystem: "com.unlikelyware.bonjour1", category: "Browser")
}

protocol BrowserDelegate {
	func needsUpdate()
}
