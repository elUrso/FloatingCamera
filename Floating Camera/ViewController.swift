//
//  ViewController.swift
//  Camera Feed
//
//  Created by Vitor Silva on 21/05/20.
//  Copyright © 2020 Vitor Silva. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, NSWindowDelegate {
    var preview: AVCaptureVideoPreviewLayer! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.setupCaptureSession()
            
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession()
                    }
                }
            
            case .denied: // The user has previously denied access.
                self.setupNotEnoughPermission()

            case .restricted: // The user can't grant access due to restrictions.
                self.setupNotEnoughPermission()
        @unknown default:
            self.setupNotEnoughPermission()
        }
    }
    
    override func viewDidAppear() {
        view.window?.delegate = self
        view.window?.level = .floating
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setupCaptureSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        if let video = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) {
            let input = try! AVCaptureDeviceInput(device: video)
            session.addInput(input)
        }
        
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer?.addSublayer(preview)
        session.commitConfiguration()
        session.startRunning()
    }
    
    func setupNotEnoughPermission() {
        let alert = NSAlert();
        alert.messageText = "Unable to access camera"
        alert.informativeText = "Unable to access camera due to lack of permissions"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        preview.frame.size = frameSize
        return frameSize
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(nil)
    }
}
