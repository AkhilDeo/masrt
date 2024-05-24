//==============================================================================
/*
#     Software License Agreement (BSD License)
#     Copyright (c) 2024 Akhil Deo <adeo1@jhu.edu>


#     All rights reserved.

#     Redistribution and use in source and binary forms, with or without
#     modification, are permitted provided that the following conditions
#     are met:

#     * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.

#     * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.

#     * Neither the name of authors nor the names of its contributors may
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.

#     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#     COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#     POSSIBILITY OF SUCH DAMAGE.


#     \author    <adeo1@jhu.edu>
#     \author    Akhil Deo
#     \version   1.0
# */
//==============================================================================

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
