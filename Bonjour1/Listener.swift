//
//  Listener.swift
//  Bonjour1
//
//  Created by Eric Kampman on 5/12/21.
//

import Foundation
import Network
import os

var gListener: Listener?

class Listener: NSObject {

//	weak var delegate: PeerConnectionDelegate?
	var listener: NWListener?
	var name = "Bonjour1Test"

	init(name: String, delegate: ConnectionDelegate) {
		super.init()
		
		self.name = name
		self.delegate = delegate
	}
	
	func listen() {
		do {
			// Create the listener object.
			let listener = try NWListener(using: .tcp)
			self.listener = listener
			
			// Set the service to advertise.
			listener.service = NWListener.Service(name: self.name, type: browserType)

			listener.stateUpdateHandler = { newState in
				switch newState {
				case .setup: 				//The listener has been initialized but not started.
					self.logger.debug("Listener Set Up")
				case .waiting(let error): 	// The listener is waiting for a network to become available.
					self.logger.error("Listener Waiting: \(error.debugDescription)")
				case .ready: 				// The listener is running and able to receive incoming connections.
					self.logger.debug("Listener Ready")
				case .failed(let error): 	// The listener has encountered a fatal error.
					self.logger.error("Listener Error: \(error.debugDescription)")
				case .cancelled:			// The listener has been canceled.
					self.logger.debug("Listener Cancelled")
				@unknown default:
					self.logger.debug("Listener Unknown State")
				}
			}
			
			listener.newConnectionHandler = { newConnection in
				if let delegate = self.delegate {
					if gConnection == nil {
						// Accept a new connection.
						gConnection = Connection(connection: newConnection, delegate: delegate)
					} else {
						// If a game is already in progress, reject it.
						newConnection.cancel()
					}
				}
			}

			// Start listening, and request updates on the main queue.
			listener.start(queue: .main)

		} catch {
			
		}
	}
	
	func resetName(_ name: String) {
		self.name = name
		if let listener = listener {
			// Reset the service to advertise.
			listener.service = NWListener.Service(name: self.name, type: browserType)
		}
	}

	weak var delegate: ConnectionDelegate?
	let logger = Logger(subsystem: "com.unlikelyware.bonjour1", category: "Listener")
	let browserType = "_bonjour1._tcp"
}
