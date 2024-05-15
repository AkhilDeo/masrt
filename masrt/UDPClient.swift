//
//  UDPClient.swift
//  ARPersistence
//
//  Created by Akhil Deo on 4/12/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Network
import Foundation

protocol UDPListener {
    func handleResponse(_ client: UDPClient, data: Data)
}

class UDPClient {
    
    var connection: NWConnection
    var address: NWEndpoint.Host
    var port: NWEndpoint.Port
    var delegate: UDPListener?
    
    var resultHandler = NWConnection.SendCompletion.contentProcessed { NWError in
        guard NWError == nil else {
            print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            return
        }
    }
    
    init?(address newAddress: String, port newPort: Int32) {
        guard let codedAddress = IPv4Address(newAddress),
              let codedPort = NWEndpoint.Port(rawValue: NWEndpoint.Port.RawValue(newPort)) else {
            print("Failed to create connection address")
            return nil
        }
        address = .ipv4(codedAddress)
        port = codedPort
        NWParameters.udp.allowLocalEndpointReuse = true
        
        connection = NWConnection(host: address, port: port, using: .udp)
        connection.stateUpdateHandler = { newState in
            switch (newState) {
            case .ready:
                print("State: Ready")
                return
            case .setup:
                print("State: Setup")
            case .cancelled:
                print("State: Cancelled")
            case .preparing:
                print("State: Preparing")
            default:
                print("ERROR! State not defined!\n")
            }
        }
        connection.start(queue: .global())
    }
    
    func close() {
        connection.cancel()
    }
    
    deinit {
        connection.cancel()
    }
    
    func send(_ data: Data) {
        self.connection.send(content: data, completion: .idempotent)
    }
    
    func sendTest(_ payload: Data) {
        self.connection.send(content: payload, completion: .contentProcessed({ sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
            } else {
                NSLog("Data has been sent")
                self.connection.receiveMessage { (data, context, isComplete, error) in
                    NSLog("Made it here")
                    guard let myData = data else { return }
                    NSLog("Received message: " + String(decoding: myData, as: UTF8.self))
                }
            }
        }))
    }
    
    private func listen() {
        connection.receiveMessage { data, context, isComplete, error in
            print("Receive isComplete: " + isComplete.description)
            guard let myData = data else {
                print("Error: Received nil Data")
                return
            }
            print("Data Received")
            print(myData)
        }
        
    }
    
    
    
    
}
