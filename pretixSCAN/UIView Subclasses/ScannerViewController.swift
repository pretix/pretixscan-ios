//
//  ScanViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 27.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import AVFoundation
import UIKit
import Combine

/// Generic ViewController Superclass to scan barcodes and QR codes.
///
/// To subclass:
/// - subclass and override the `found()` method to know what to do with found QR Codes
/// - set `shouldScan` to `true` to start scanning, to `false` to stop scanning after you found something
class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    /// Period between scans when the timer will not fire
    var gracePeriod: TimeInterval = 2
    
    /// If `true`, scanning will be active
    var shouldScan = false {
        didSet {
            logger.debug("📸 should scan was set")
            if shouldScan && canUseCamera {
                hideNoCameraView()
                startScanning()
            } else {
                stopScanning()
                if !canUseCamera {
                    showNoCameraView()
                }
            }
        }
    }
    
    var canUseCamera = true
    var preferFrontCamera = false
    
    private var lastFoundAt: Date = Date.distantPast
    
    private var avCaptureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession!
    private var previewLayerIsInitialized = false
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var metadataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var anyCancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNoCameraView()
        view.backgroundColor = UIColor.darkGray
        captureSession = AVCaptureSession()
        
        avCaptureDevice = Self.getCaptureDevice(useFrontCamera: preferFrontCamera)
        guard let videoCaptureDevice = avCaptureDevice else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .pdf417]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayerIsInitialized = true
        
        // Tap Gestures
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleFlash))
        view.addGestureRecognizer(tapGestureRecognizer!)
        
        NotificationCenter.default
            .publisher(for: Notification.Name("ConfigStoreChanged"))
            .throttle(for: 1, scheduler: DispatchQueue.global(qos: .userInitiated), latest: true)
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] notification in
                self?.onConfigStoreChanged(notification)
            })
            .store(in: &anyCancellables)
    }
    
    func failed() {
        EventLogger.log(event: "Failed to create Capture Session", category: .avCaptureDevice, level: .error, type: .fault)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldScan {
            startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard previewLayerIsInitialized else {
            return
        }
        
        super.viewDidLayoutSubviews()
        previewLayer.removeFromSuperlayer()
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        if previewLayer.connection?.isVideoOrientationSupported == true {
            guard let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation else {
                logger.warning("Unknown interfaceOrientation")
                return
            }
            switch interfaceOrientation {
            case .unknown, .portraitUpsideDown, .portrait:
                previewLayer.connection?.videoOrientation = .portrait
            case .landscapeLeft:
                previewLayer.connection?.videoOrientation = .landscapeLeft
            case .landscapeRight:
                previewLayer.connection?.videoOrientation = .landscapeRight
            @unknown default:
                previewLayer.connection?.videoOrientation = .portrait
            }
        }
    }
    
    private func startScanning() {
        logger.debug("📸 start scanning")
        try? reconfigureRunningSession()
        guard Self.getCaptureDevice(useFrontCamera: preferFrontCamera) != nil else { return }
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    private func reconfigureRunningSession() throws {
        logger.debug("📸 reconfigure capture session")
        
        if captureSession == nil || captureSession?.isRunning != true {
            // no session or not a running session
            logger.debug("📸 nothing to reconfigure")
            return
        }
        
        captureSession?.beginConfiguration()
        
        // remove inputs
        for input in captureSession?.inputs ?? [] {
            captureSession?.removeInput(input)
        }
        
        // get new input
        avCaptureDevice = Self.getCaptureDevice(useFrontCamera: preferFrontCamera)
        guard let videoCaptureDevice = avCaptureDevice else { return }
        
        let videoInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        captureSession?.commitConfiguration()
    }
    
    private func stopScanning() {
        guard Self.getCaptureDevice(useFrontCamera: preferFrontCamera) != nil else { return }
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        guard -(lastFoundAt.timeIntervalSinceNow) > gracePeriod else { return }
        lastFoundAt = Date()
        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        
        found(code: stringValue)
    }
    
    /// Toggle the Flashlight on and off if possible
    ///
    /// https://stackoverflow.com/a/27334447/54547
    @objc func toggleFlash() {
        guard let device = avCaptureDevice else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == .on {
                if device.isTorchModeSupported(.off) {
                    device.torchMode = .off
                }
            } else {
                if device.isTorchModeSupported(.on) {
                    device.torchMode = .on
                }
            }
        } catch {
            EventLogger.log(event: "Failed to lock AVCaptureDevice for configuration: \(String(describing: error))", category: .avCaptureDevice, level: .error, type: .fault)
        }
        
        device.unlockForConfiguration()
    }
    
    // Override this method in yuor subclass
    func found(code: String) {
        print(code)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Enable  or disable camera
    func onConfigStoreChanged(_ notification: Notification) {
        guard let value = notification.userInfo?["value"] as? ConfigStoreValue, let configStore = notification.object as? ConfigStore else {
            return
        }
        if [.useDeviceCamera, .preferFrontCamera].contains(value) {
            preferFrontCamera = configStore.preferFrontCamera
            if configStore.useDeviceCamera == true {
                canUseCamera = true
                shouldScan = true
            } else {
                canUseCamera = false
                shouldScan = false
            }
        }
    }
    
    var noCameraView: UIView? = nil
    
    func hideNoCameraView() {
        logger.debug("Hiding no camera view")
        previewLayer.isHidden = false
        noCameraView?.isHidden = true
    }
    
    func showNoCameraView() {
        logger.debug("Showing no camera view")
        previewLayer.isHidden = true
        noCameraView?.isHidden = false
    }
    
    func configureNoCameraView() {
        let customView = UIView()
        customView.isHidden = true
        customView.isUserInteractionEnabled = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.backgroundColor = UIColor.black
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = PXColor.secondary
        label.text = Localization.SettingsTableViewController.ConnectExternalDevice
        label.textAlignment = .center
        
        customView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: customView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: customView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
        ])
        
        view.addSubview(customView)
        
        noCameraView = customView
        
        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            customView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private static func getCaptureDevice(useFrontCamera: Bool) -> AVCaptureDevice? {
        logger.debug("📸 getCaptureDevice, useFrontCamera: \(useFrontCamera)")
        if !useFrontCamera {
            return AVCaptureDevice.default(for: .video)
        }
        
        // try to get a front-facing camera and if that's not possible, fallback to the default video camera.
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ?? AVCaptureDevice.default(for: .video)
    }
}


