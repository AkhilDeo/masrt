//
//  UDPClient.swift
//  ARPersistence
//
//  Created by Akhil Deo on 4/12/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Network
import Foundation

class UDPClientTest {
    
    var connection: NWConnection
    var address: NWEndpoint.Host
    var port: NWEndpoint.Port
    var delegate: UDPListener?
    var receivedString: String = ""
    
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
                self.send("{\"test\": \"true\"}".data(using: .utf8)!)
                self.receivedString = self.receiveUDP()
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
    
    func receiveUDP() -> String {
        var retVal: String = ""
        self.connection.receiveMessage { (data, context, isComplete, error) in
            if (isComplete) {
                print("Receive is complete")
                if (data != nil) {
                    let backToString = String(decoding: data!, as: UTF8.self)
                    print("Received message: \(backToString)")
                    retVal = backToString
                } else {
                    print("Data == nil")
                }
            }
        }
        return retVal
    }
    
    
}
