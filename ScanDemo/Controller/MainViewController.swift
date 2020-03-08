//
//  MainViewController.swift
//  ScanDemo
//
//  Created by 曾钊 on 2020/3/7.
//  Copyright © 2020 曾钊. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var scanButton: UIBarButtonItem!
    @IBOutlet weak var tableviewTopConstraint: NSLayoutConstraint!
    
    var scanManager: ScanManager!
    
    private var kvoContext = 0
    
    //MARK: - View On Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set navigation bar
        navigationItem.title = "LAN Devices Scan"
        
        //Initial scanManager with delegate
        self.scanManager = ScanManager(delegate: self)
        
        //Add observers to monitor
        self.addObserverForKVO()
        
        tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 80
    }
    
    //MARK: - KVO Observers Method
    func addObserverForKVO() {
        self.scanManager.addObserver(self, forKeyPath: "connectedDevices", options: .new, context:&kvoContext)
        self.scanManager.addObserver(self, forKeyPath: "progressValue", options: .new, context:&kvoContext)
        self.scanManager.addObserver(self, forKeyPath: "isScanRunning", options: .new, context:&kvoContext)
    }
    
    func removeObserverForKVO() {
        self.scanManager.removeObserver(self, forKeyPath: "connectedDevices")
        self.scanManager.removeObserver(self, forKeyPath: "progressValue")
        self.scanManager.removeObserver(self, forKeyPath: "isScanRunning")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            switch keyPath! {
            case "connectedDevices":
                self.tableView.reloadData()
            case "progressValue":
                self.progressView.progress = self.scanManager.progressValue
            case "isScanRunning":
                let isScanRunning = change?[.newKey] as! BooleanLiteralType
                self.scanButton.image = isScanRunning ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "refresh")
            default:
                print("No valid key for observing.")
            }
        }
    }
    
    //MARK: - Refresh Button Clicked
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        showProgressView()
        navigationItem.title = "Scanning"
        scanManager.scanButtonPressed()
    }
    
    //MARK: - Progress View Show/Hide Methods
    func showProgressView() {
        progressView.progress = 0
        
        UIView.animate(withDuration: 0.5) {
            self.tableviewTopConstraint.constant = 4
            self.view.layoutIfNeeded()
        }
        
    }
    
    func hideProgressView() {
        UIView.animate(withDuration: 0.5) {
            self.tableviewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Alert Controller Function
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Deinitial
    deinit {
        removeObserverForKVO()
    }
    
    
}

//MARK: - ScanManager Delegate
extension MainViewController: ScanManagerDelegate {
    func scanIPAddressesFinished() {
        hideProgressView()
        showAlert(title: "Scan finished", message: "Number of devices connected to LAN: \(scanManager.connectedDevices.count)")
    }
    
    func scanIPAddressesCancelled() {
        hideProgressView()
        tableView.reloadData()
    }
    
    func scanIPAddressesFailed() {
        hideProgressView()
        showAlert(title: "Failed to scan", message: "Please make sure you are connected to a WiFi before starting")
    }
    
}

//MARK: - UITableView Delegate&Datasource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanManager.connectedDevices!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DeviceCell
        let device = scanManager.connectedDevices[indexPath.row]
        
        cell.ipAddrLabel.text = device.ipAddress
        if device.macAddress == nil || device.macAddress == "02:00:00:00:00:00" {
            cell.macLabel.text = "MAC unavailable"
        } else {
            cell.macLabel.text = String(format: "MAC: %@", device.macAddress)
        }
        cell.hostName.text = device.hostname
        cell.brand.text = device.brand
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToPortView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PortStatusViewController
        
    }
}
