//
//  ScanManager.swift
//  ScanDemo
//
//  Created by 曾钊 on 2020/3/7.
//  Copyright © 2020 曾钊. All rights reserved.
//
import UIKit
import CoreData

protocol ScanManagerDelegate {
    func scanIPAddressesFinished()
    func scanIPAddressesCancelled()
    func scanIPAddressesFailed()
}

class ScanManager: NSObject, MMLANScannerDelegate {
    
    //KVO Objects
    @objc dynamic var connectedDevices : [MMDevice]!
    @objc dynamic var progressValue : Float = 0.0
    @objc dynamic var isScanRunning : Bool = false
    
    //Create CoreData to store Data
    @objc dynamic var devicesLocal = [CDevice]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("localDevices.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var lanScanner: MMLANScanner!
    
    var delegate: ScanManagerDelegate?
    
    init(delegate: ScanManagerDelegate?) {
        super.init()
        
        self.delegate = delegate!
        
        self.connectedDevices = [MMDevice]()
        self.isScanRunning = false
        self.lanScanner = MMLANScanner(delegate: self)
        
    }
    
    //MARK: - Scan Logic for Scan Button Pressed
    func scanButtonPressed() {
        if isScanRunning {
            stopNetworkScan()
        } else {
            startNetworkScan()
        }
    }
    
    func startNetworkScan() {
        if isScanRunning {
            stopNetworkScan()
            connectedDevices.removeAll()
            removeAllDevice()
        } else {
            connectedDevices.removeAll()
            removeAllDevice()
            isScanRunning = true
            lanScanner.start()
        }
    }
    
    func stopNetworkScan() {
        lanScanner.stop()
        isScanRunning = false
    }
    
    //MARK: - GET SSID INFO
    func ssidName() -> String {
        return LANProperties.fetchSSIDInfo()
    }
    
    //MARK: - CoreData Methods
    func saveDevice() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }

    func loadDevice() {
        let request : NSFetchRequest<CDevice> = CDevice.fetchRequest()

        do {
            devicesLocal = try context.fetch(request)
            for deviceL in devicesLocal {
                let device = MMDevice()
                device.hostname = deviceL.hostname
                device.brand = deviceL.brand
                device.ipAddress = deviceL.ipAddress
                device.macAddress = deviceL.macAddress
                
                self.connectedDevices.append(device)
                
            }
            print(devicesLocal)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }

    func removeAllDevice() {
        let fetchRequest : NSFetchRequest<CDevice> = CDevice.fetchRequest()
//        fetchRequest.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData: CDevice = managedObject as CDevice
                context.delete(managedObjectData)
            }
        } catch {
            print("Error deleting all objects: \(error)")
        }

        devicesLocal.removeAll()
        
        saveDevice()

    }
    
    //MARK: - MMLANScanner Delegate
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        if(!self.connectedDevices.contains(device)) {
            self.connectedDevices?.append(device)
            
            //Data localize
            let newDevice = CDevice(context: self.context)
            newDevice.brand = device.brand
            newDevice.hostname = device.hostname
            newDevice.ipAddress = device.ipAddress
            newDevice.macAddress = device.macAddress
            devicesLocal.append(newDevice)
            
            self.saveDevice()
        }
        
        
        let ipSortDescriptor = NSSortDescriptor(key: "ipAddress", ascending: true)
        
        let request : NSFetchRequest<CDevice> = CDevice.fetchRequest()
        let ipSortDescriptors = [ipSortDescriptor]
        request.sortDescriptors = ipSortDescriptors
        
        self.connectedDevices = ((self.connectedDevices as NSArray).sortedArray(using: [ipSortDescriptor]) as! Array)
        
    }
    
    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        self.isScanRunning = false
        
        if status == MMLanScannerStatusFinished {
            self.delegate?.scanIPAddressesFinished()
        } else if status == MMLanScannerStatusCancelled {
            self.delegate?.scanIPAddressesCancelled()
        }
        
    }
    
    func lanScanDidFailedToScan() {
        self.isScanRunning = false
        self.delegate?.scanIPAddressesFailed()
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        progressValue = pingedHosts / Float(overallHosts)
    }
}
