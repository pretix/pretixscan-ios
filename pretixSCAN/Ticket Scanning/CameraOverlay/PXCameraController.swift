//
//  PXCameraController.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import UIKit
import AVFoundation
import Combine


final class PXCameraController: UIViewController {
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    
    weak var delegate: PXCameraControllerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var previewLayerIsInitialized = false
    private var anyCancellables = Set<AnyCancellable>()
    
    var preferFrontCamera: Bool = false
    var applyVideoTransformation: Bool {
        return !self.preferFrontCamera
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePhotoButton.setTitle(Localization.QuestionsTableViewController.TakePhotoAction, for: .normal)
        
        guard let preferredCamera = Self.getCaptureDevice(useFrontCamera: preferFrontCamera) else {
            logger.error("Unable to access the device camera!")
            onError()
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        do {
            let input = try AVCaptureDeviceInput(device: preferredCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer.videoGravity = .resizeAspect
                // videoPreviewLayer.connection?.videoOrientation = .portrait
                
                previewView.layer.addSublayer(videoPreviewLayer)
                
                previewLayerIsInitialized = true
            } else {
                onError()
            }
        }
        catch let error  {
            logger.error("Unable to initialize back camera:  \(error.localizedDescription)")
            onError()
            return
        }
        
        NotificationCenter.default.publisher(for: .AVCaptureSessionWasInterrupted)
            .sink(receiveValue: {[weak self] n in
                logger.debug("📸 AVCaptureSessionWasInterrupted")
                if let cs = self?.captureSession, cs == n.object as? AVCaptureSession {
                    self?.onError()
                }
            })
            .store(in: &anyCancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard previewLayerIsInitialized else {
            return
        }
                
        if videoPreviewLayer.connection?.isVideoOrientationSupported == true {
            guard let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation else {
                logger.warning("Unknown interfaceOrientation")
                return
            }
            
            videoPreviewLayer.frame = previewView.layer.bounds
                    
            
            switch interfaceOrientation {
            case .unknown, .portrait:
                videoPreviewLayer.connection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
            case .landscapeRight:
                videoPreviewLayer.connection?.videoOrientation = .landscapeRight
            @unknown default:
                videoPreviewLayer.connection?.videoOrientation = .portrait
            }
        }
        
        if !applyVideoTransformation, let connection = videoPreviewLayer.connection {
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        if let connection = stillImageOutput.connection(with: .video) {
            // Ensure the mirroring is preserved when photo is taken
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func startScanning() {
        logger.debug("📸 start scanning")
        try? reconfigureRunningSession()
        guard Self.getCaptureDevice(useFrontCamera: preferFrontCamera) != nil else { return }
        if captureSession != nil && captureSession.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }

    private func stopScanning() {
        guard Self.getCaptureDevice(useFrontCamera: preferFrontCamera) != nil else { return }
        if captureSession != nil && captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func onError() {
        self.stopScanning()
        dismiss(animated: false)
        delegate?.onPhotoCaptureCancelled()
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
        let avCaptureDevice = Self.getCaptureDevice(useFrontCamera: preferFrontCamera)
        guard let videoCaptureDevice = avCaptureDevice else { return }
        
        let videoInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        captureSession?.commitConfiguration()
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

extension PXCameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
        else {
            logger.error("Unable to obtain file representation of photo")
            onError()
            return
        }
        guard let image = UIImage(data: imageData) else {
            logger.error("Unable to represent imageData as a UIImage.")
            onError()
            return
        }
        delegate?.onPhotoCaptured(image)
        dismiss(animated: false)
    }
}


protocol PXCameraControllerDelegate: AnyObject {
    func onPhotoCaptured(_ uiImage: UIImage)
    func onPhotoCaptureCancelled()
}
