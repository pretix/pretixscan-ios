//
//  PXCameraController.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 14/03/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import UIKit
import AVFoundation

final class PXCameraController: UIViewController {
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    
    weak var delegate: PXCameraControllerDelegate?
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePhotoButton.setTitle(Localization.QuestionsTableViewController.TakePhotoAction, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        else {
            logger.error("Unable to access back camera!")
            onError()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            } else {
                onError()
            }
        }
        catch let error  {
            logger.error("Unable to initialize back camera:  \(error.localizedDescription)")
            onError()
            return
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                guard let previewBounds = self?.previewView.bounds else {
                    return
                }
                self?.videoPreviewLayer.frame = previewBounds
            }
        }
        
    }
    
    func onError() {
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
        dismiss(animated: true)
    }
}


protocol PXCameraControllerDelegate: AnyObject {
    func onPhotoCaptured(_ uiImage: UIImage)
    func onPhotoCaptureCancelled()
}
