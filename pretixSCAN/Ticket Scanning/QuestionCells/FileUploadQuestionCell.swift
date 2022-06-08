//
//  FileUploadQuestionCell.swift
//  pretixSCAN
//
//  Created by Daniel Jilg on 13.08.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class FileUploadQuestionCell: QuestionCell {
    override class var reuseIdentifier: String { return "FileUploadQuestionCell" }
    static let UploadSize: CGSize = CGSize(width: 900, height: 1200)
    static let ThumbnailSize: CGSize = CGSize(width: 300, height: 400)
    static let Padding: CGFloat = 15
    
    
    let takePictureButton: UIButton = {
        let submit = ChoiceButton()
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle(Localization.QuestionsTableViewController.TakePhotoAction, for: .normal)
        return submit
    }()
    
    
    let thumbnailPreview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = PXColor.primary.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let placeholderView: UIView = {
        let background = UIView()
        background.backgroundColor = PXColor.grayBackground
        background.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: "camera.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: background.centerYAnchor)
        ])
        
        return background
    }()
    
    override func setup() {
        super.setup()
        
        let cellView = UIView()
        
        // if the user taps on the thumbnail or the placeholder, initiate image picker
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePicture(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = true
        
        // placeholder for where the thumbnail will be
        placeholderView.isUserInteractionEnabled = true
        placeholderView.addGestureRecognizer(tapRecognizer)
        cellView.addSubview(placeholderView)
        
        // the thumbnail will cover the placeholder
        thumbnailPreview.isUserInteractionEnabled = true
        thumbnailPreview.addGestureRecognizer(tapRecognizer)
        cellView.addSubview(thumbnailPreview)
        
        // take a photo button
        cellView.addSubview(takePictureButton)
        
        NSLayoutConstraint.activate([
            placeholderView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: Self.Padding),
            placeholderView.topAnchor.constraint(equalTo: cellView.topAnchor, constant:  Self.Padding),
            placeholderView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -Self.Padding),
            placeholderView.widthAnchor.constraint(equalToConstant: Self.ThumbnailSize.width / 2),
            
            thumbnailPreview.widthAnchor.constraint(equalTo: placeholderView.widthAnchor),
            thumbnailPreview.heightAnchor.constraint(equalTo: placeholderView.heightAnchor),
            thumbnailPreview.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            thumbnailPreview.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            
            takePictureButton.leadingAnchor.constraint(equalTo: placeholderView.trailingAnchor, constant:  Self.Padding),
            takePictureButton.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -Self.Padding),
            takePictureButton.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            
            cellView.heightAnchor.constraint(equalToConstant: (Self.ThumbnailSize.height / 2) + 2 * Self.Padding)
        ])
        
        // open the image picker when the button is tapped
        takePictureButton.addTarget(self, action: #selector(takePicture(_:)), for: .touchUpInside)
        
        
        
        mainStackView.addArrangedSubview(cellView)
    }
    
    
    @objc func takePicture(_ sender: AnyObject) {
        guard let vc = UIStoryboard.init(name: "Camera", bundle: Bundle.main).instantiateViewController(withIdentifier: "takePicture") as? PXCameraController else {
            logger.error("PXCameraController not found in storyboard!")
            return
        }
        
        vc.delegate = self
        
        
        self.delegate?.present(vc, animated: true, completion: nil)
    }
    
    func onPictureUpdated(thumbnail: UIImage, file: PXTemporaryFile) {
        logger.debug("Picture taken and saved at \(file), updating thumbnail")
        thumbnailPreview.image = thumbnail
        
        let updatedAnswer = Answer(questionIdentifier: question!.identifier, fileUrl: file.contentURL)
        delegate?.answerUpdated(for: indexPath, newAnswer: updatedAnswer)
    }
    
    func onFailedToTakePicture() {
        logger.debug("Taking a picture aborted")
    }
}

extension FileUploadQuestionCell: PXCameraControllerDelegate {
    func onPhotoCaptured(_ uiImage: UIImage) {
        let image = uiImage
        
        DispatchQueue.global(qos: .userInitiated).async {
            logger.debug("📸 resizing picture \(String(describing: image.imageOrientation)) from \(String(describing: image.size)) to \(String(describing: FileUploadQuestionCell.ThumbnailSize)) and \(String(describing: FileUploadQuestionCell.UploadSize))")
            let uploadImage = image.resizeAndCrop(to: FileUploadQuestionCell.UploadSize)
            let thumbnailImage = image.resizeAndCrop(to: FileUploadQuestionCell.UploadSize).resize(to: FileUploadQuestionCell.ThumbnailSize)!
            // store the original image as a temporary file on the file system
            // the answer will contain the URL to the file so it can be processed at time of upload
            let temporaryFile = PXTemporaryFile(extension: "jpeg")
            if let data = uploadImage.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: temporaryFile.contentURL)
                } catch {
                    logger.error("Error writing thumbnail to temporary file at \(temporaryFile): \(String(describing: error))")
                }
            }
            
            DispatchQueue.main.async {[weak self] in
                self?.onPictureUpdated(thumbnail: thumbnailImage, file: temporaryFile)
            }
        }
    }
    
    func onPhotoCaptureCancelled() {
        onFailedToTakePicture()
    }
}
