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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePhotoButton.setTitle(Localization.QuestionsTableViewController.TakePhotoAction, for: .normal)
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            logger.error("Unable to access back camera!")
            onError()
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer.videoGravity = .resizeAspectFill
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard previewLayerIsInitialized else {
            return
        }

        super.viewDidLayoutSubviews()
        videoPreviewLayer.removeFromSuperlayer()
        videoPreviewLayer.frame = previewView.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer)

        if videoPreviewLayer.connection?.isVideoOrientationSupported == true {
            guard let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation else {
                logger.warning("Unknown interfaceOrientation")
                return
            }
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
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func startScanning() {
        guard AVCaptureDevice.default(for: .video) != nil else { return }
        if captureSession != nil && captureSession.isRunning == false {
            captureSession.startRunning()
        }
    }

    private func stopScanning() {
        guard AVCaptureDevice.default(for: .video) != nil else { return }
        if captureSession != nil && captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func onError() {
        self.stopScanning()
        dismiss(animated: false)
        delegate?.onPhotoCaptureCancelled()
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
