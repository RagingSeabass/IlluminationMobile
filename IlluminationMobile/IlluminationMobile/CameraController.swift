//
//  CameraController.swift
//  IlluminationMobile
//
//  Created by Christian Schmidt on 08/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

import AVFoundation
import UIKit
import VideoToolbox

class CameraController: NSObject, AVCapturePhotoCaptureDelegate {
    
    var session: AVCaptureSession?
    var camera: AVCaptureDevice?
    var cameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var completionBlock: ((UIImage?, Error?) -> Void)?
    var photoSettings: AVCapturePhotoSettings?
    
    func getPermissions() -> Bool {
        var authorized = false
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                authorized = true
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        authorized = true
                    }
                }
            case .denied: // The user has previously denied access.
                authorized = false
            case .restricted: // The user can't grant access due to restrictions.
                authorized = false
        }
        return authorized
    }
    
    func setup() {
        // Setup session
        self.session = AVCaptureSession()
        // Setup camera device
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        let cameras = discoverySession.devices.compactMap { $0 }
        self.camera = cameras[0]
        
        if let device = self.camera {
            do {
                // Configure camera
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
                // Configure camera input
                self.cameraInput = try AVCaptureDeviceInput(device: device)
                session?.addInput(self.cameraInput!)
            } catch {
                print(error)
            }
        }
        // Setup camera output
        let photoSettings = [AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])]
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput!.setPreparedPhotoSettingsArray(photoSettings, completionHandler: nil)
        self.session?.addOutput(self.photoOutput!)
        self.session!.startRunning()
        // High res
        //self.session?.sessionPreset = AVCaptureSession.Preset.photo;
    }
    
    func setupPreviewLayer(on previewLayer: UIView) {
        // Setup preview layer
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
        self.cameraPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer!.connection?.videoOrientation = .portrait
        previewLayer.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        self.cameraPreviewLayer!.frame = previewLayer.frame
    }
    
    func capture(iso: Float, shutterTime: CMTime, changeSettings: Bool, completionBlock: @escaping (UIImage?, Error?) -> Void) {
        
        // Completion block handles image after capture
        self.completionBlock = completionBlock
        
        let pixelFormatType = kCVPixelFormatType_32BGRA
        guard self.photoOutput!.availablePhotoPixelFormatTypes.contains(pixelFormatType) else { return }
        self.photoSettings = AVCapturePhotoSettings(format:
            [ kCVPixelBufferPixelFormatTypeKey as String : pixelFormatType ])
        
        //print(self.camera?.activeFormat.maxISO)
        //print(self.camera?.activeFormat.maxExposureDuration)
        
        if let device = self.camera {
            do {
                if (changeSettings) {
                    // Set ISO and exposure time
                    try device.lockForConfiguration()
                    print(iso)
                    print(shutterTime)
                    device.setExposureModeCustom(duration:shutterTime, iso: iso, completionHandler: captureCompletion)
                    device.unlockForConfiguration()
                } else {
                    captureCompletion()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func captureCompletion(completionTime: CMTime) {
        self.photoOutput?.capturePhoto(with: self.photoSettings!, delegate: self)
    }
    
    func captureCompletion() {
        self.photoOutput?.capturePhoto(with: self.photoSettings!, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            self.completionBlock?(nil, error)
            return
        }
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(photo.pixelBuffer!, options: nil, imageOut: &cgImage)
        let image = UIImage.init(cgImage: cgImage!)
        //let imagepng = CIImage(cvPixelBuffer: photo.pixelBuffer!)
        //let image = UIImage.init(cgImage: imagepng as! CGImage)
        /*guard let data = photo.fileDataRepresentation() else {
            self.completionBlock?(nil, error)
            return
        }
        
        guard let image = UIImage(data: data) else {
            self.completionBlock?(nil, error)
            return
        }*/
        
        self.completionBlock?(image, nil)
    }
    
   
    func setContinuousAutoExposure() {
        if let device = self.camera {
            do {
                try device.lockForConfiguration()
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
}
