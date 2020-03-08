//
//  PortStatusViewController.swift
//  ScanDemo
//
//  Created by 曾钊 on 2020/3/7.
//  Copyright © 2020 曾钊. All rights reserved.
//

import UIKit

class PortStatusViewController: UIViewController, GCDAsyncSocketDelegate {
    
    
    @IBOutlet var labels: [UILabel]!
    
    var device: MMDevice!
    
    private var allTestPorts: [UInt16] = [
        21, 22, 23, 25,
        53, 80, 110, 115,
        135, 139, 143, 194,
        443, 445, 1433, 1521,
        3306, 3389, 5632, 5900,
        8080, 9200, 10000, 22122
    ]
    private var isConnected: Bool = false
    private var socket: GCDAsyncSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Port Status"
        
        //Scan the ports
        for i in 0..<self.allTestPorts.count {
            self.connectToHost(ipAddress: self.device.ipAddress, onPort: self.allTestPorts[i])
        }
            
        
    }
    
    //MARK: - Socket methods
    func connectToHost(ipAddress: String, onPort port: UInt16) {
        
        do {
            socket = GCDAsyncSocket(delegate: (self as GCDAsyncSocketDelegate), delegateQueue: DispatchQueue.main)
            if socket.isDisconnected == false {
                self.socket.disconnect()
            }
            
            try socket.connect(toHost: ipAddress, onPort: port, withTimeout: 1)
        } catch {
            print("Error connected to host on port: \(error)")
        }
    }
    
    //Success connected
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sock.readData(withTimeout: 1, tag: 0)
        
        DispatchQueue.main.async {
            //iterator which label should be changed
            let index = self.allTestPorts.firstIndex(of: port)
            self.labels[index!].textColor = .systemGreen
        }
        
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected")
    }
    
    
}
