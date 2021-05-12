//
//  Connection.swift
//  Bonjour1
//
//  Created by Eric Kampman on 5/12/21.
//

import Foundation
import Network
import os


var gConnection: Connection?

protocol ConnectionDelegate: AnyObject {
	func needsUpdate()
}

class Connection: NSObject {
	weak var delegate: ConnectionDelegate?
	var connection: NWConnection?
	var initiated = false

	// we are initiating
	init(endpoint: NWEndpoint, delegate: ConnectionDelegate)
	{
		super.init()
		
		self.delegate = delegate
		let connection = NWConnection(to: endpoint, using: .tcp)
		self.connection = connection
		self.initiated = true
		
		self.start()
	}
	
	init(connection: NWConnection, delegate: ConnectionDelegate)
	{
		super.init()
		
		self.delegate = delegate
		self.connection = connection

		self.start()
	}

	func start() {
		guard let connection = connection else {
			return
		}

		connection.stateUpdateHandler = { newState in
			switch newState {
			case .setup: 				//The connection has been initialized but not started.
				self.logger.debug("Connection Set Up")
			case .waiting(let error): 	// The connection is waiting for a network path change.
				self.logger.error("Connection Waiting: \(error.debugDescription)")
			case .preparing: 			// The connection in the process of being established.
				self.logger.debug("Connection Set Up")
			case .ready:				// The connection is established, and ready to send and receive data.
				self.logger.debug("Connection Set Up")
			case .failed(let error):	// The connection has disconnected or encountered an error.
				self.logger.error("Connection Waiting: \(error.debugDescription)")
			case .cancelled:			// The connection has been canceled.
				self.logger.debug("Connection Set Up")
			@unknown default:
				self.logger.debug("Connection Unknown State")
			}
		}
	}
			
	let logger = Logger(subsystem: "com.unlikelyware.bonjour1", category: "Listener")
	let browserType = "_bonjour1._tcp"
}
