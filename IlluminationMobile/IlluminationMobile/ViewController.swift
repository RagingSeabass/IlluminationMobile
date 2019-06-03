//
//  ViewController.swift
//  IlluminationMobile
//
//  Created by Christian Schmidt on 08/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

import UIKit
import Photos
import Alamofire

class ViewController: UIViewController {
    
    
    // MARK: Properties
    
    
    @IBOutlet weak var captureButton: CaptureButton!
    @IBOutlet weak var refIsoLabel: UILabel!
    @IBOutlet weak var refSSLabel: UILabel!
    @IBOutlet weak var inCountLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var cameraPreview: UIView!
    let cameraController = CameraController()
    // Reference image
    var refImage: UIImage? = nil
    let imageCountReference: Int = 10
    var imageListReference: [UIImage] = []
    var ISOReference: Float = 464
    var shutterTimeReference = CMTimeMake(value: 5, timescale: 10)
    // Input images
    var inputImages: [UIImage] = []
    var isoList: [Float] = [200, 200, 200, 200, 200]
    var shutterTimeList: [CMTime] = [CMTimeMake(value: 5, timescale: 80),
                                     CMTimeMake(value: 5, timescale: 80),
                                     CMTimeMake(value: 5, timescale: 70),
                                     CMTimeMake(value: 5, timescale: 60),
                                     CMTimeMake(value: 5, timescale: 50)]
    // Synchronization
    let groupReference = DispatchGroup()
    let groupInput = DispatchGroup()
    let queue = DispatchQueue(label: "queue")
    let semaphore = DispatchSemaphore(value: 0)
    
    // ViewControllers
    var progressController = ProgressViewController()
    var reviewViewController = ReviewViewController()

    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup navbar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Setup progress viewController
        self.progressController = self.storyboard?.instantiateViewController(withIdentifier: "ProgressViewController") as! ProgressViewController
        // Setup review viewController
        self.reviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
        
        
        // Get authorization
        let authorized = self.cameraController.getPermissions()
        if (authorized) {
            self.cameraController.setup()
            self.cameraController.setupPreviewLayer(on: self.cameraPreview)
        } else {
            // Handle
        }
        self.setupVisuals()
    }
    
    func setupVisuals() {
        self.toolbarView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.00)
        self.infoView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        self.refIsoLabel.text = String(Int(self.ISOReference))
        self.refSSLabel.text = String(CMTimeGetSeconds(self.shutterTimeReference))
        self.inCountLabel.text = String(self.isoList.count)
        
        self.captureButton.setTitleColor(UIColor(red: 123/255, green: 58/255, blue: 228/255, alpha: 1), for: .normal)
        self.captureButton.titleLabel?.font =  UIFont(name: "Futura", size: 20)
        self.captureButton.setTitle("", for: .normal)
    }
    
    // MARK: Actions
    @IBAction func captureButtonPressed(_ sender: UIButton) {
        // Countdown
        var num = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) in
            
            if( num > 0) {
                self.captureButton.setTitle(String(num), for: .normal)
                num -= 1
            }
            else {
                t.invalidate()
                // Change view, start capture when done
                self.navigationController?.pushViewController(viewController: self.progressController, animated: true, completion: self.captureImageSet)
                self.captureButton.setTitle("", for: .normal)
            }
        })
    }
    
    func captureImageSet() {
        
        // Reset
        self.refImage = nil
        self.inputImages = []
        
        self.changeCellStatusActive(cellIndex: 1)
        // Capture reference image
        self.queue.async {
            self.captureReferenceImage()
        }
        
        // Wait for reference image capture to finish
        self.groupReference.notify(queue: self.queue) {
            DispatchQueue.main.async {
                self.changeCellStatusDone(cellIndex: 1)
                // Stack reference image
                self.changeCellStatusActive(cellIndex: 2)
                self.stackReferenceImage()
                self.changeCellStatusDone(cellIndex: 2)
                self.changeCellStatusActive(cellIndex: 3)
                // Capture input images
                self.captureInputImages()
                // Wait for input image capture to finish
                self.groupInput.notify(queue: self.queue) {
                    self.changeCellStatusDone(cellIndex: 3)
                    self.cameraController.setContinuousAutoExposure()
                    
                    self.changeCellStatusActive(cellIndex: 4)
                    self.changeCellStatusDone(cellIndex: 4)
                    // Move to review screen
                    sleep(1)
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(viewController: self.reviewViewController, animated: true, completion: self.addReviewImages)
                    }
                }
            }
        }
    }
    
    func captureReferenceImage() {
        print("Capturing ref image")
        // Capture each reference frame
        for i in 0...(self.imageCountReference-1) {
            self.groupReference.enter()
            print(i)
            
            var changeSettings: Bool = i == 0 ? true : false
            self.cameraController.capture(iso: self.ISOReference, shutterTime: self.shutterTimeReference, changeSettings: changeSettings, completionBlock: {(image, error) in
                guard let image = image else {
                    print(error ?? "Error in reference image capture")
                    return
                }
                self.imageListReference.append(image)
                self.semaphore.signal()
                self.groupReference.leave()
            })
            self.semaphore.wait()
        }
    }
    
    func stackReferenceImage() {
        print("Stacking ref image")
        // Stack reference frames to remove noise
        let imageListMutable = NSMutableArray(array: self.imageListReference)
        let stackImage: UIImage = ImageStacking.stackImages(imageListMutable)
    
        self.refImage = stackImage
        // Save reference image
        /*try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: stackImage)
            PHAssetChangeRequest.creationRequestForAsset(from: self.imageListReference[0])
        }*/
    }
    
    func captureInputImages() {
        
        print("Capturing input images")
        // Capture each input image
        queue.async {
            for i in 0...(self.isoList.count-1) {
                self.groupInput.enter()
                
                let iso: Float = self.isoList[i]
                let shutterTime: CMTime = self.shutterTimeList[i]
                // Capture image with custom settings
                self.cameraController.capture(iso: iso, shutterTime: shutterTime, changeSettings: true, completionBlock: {(image, error) in
                    guard let image = image else {
                        print(error ?? "Error in input image capture")
                        return
                    }
                    let imageOrientet = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .up)
                    self.inputImages.append(imageOrientet)
                    // Save input image
                    /*try? PHPhotoLibrary.shared().performChangesAndWait {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }*/
                    self.semaphore.signal()
                    self.groupInput.leave()
                })
                self.semaphore.wait()
            }
        }
    }
    
    func changeCellStatusActive(cellIndex: Int) {
        DispatchQueue.main.async {
            self.progressController.changeCellStatusActive(cellIndex: cellIndex)
        }
    }
    
    func changeCellStatusInitial() {
        DispatchQueue.main.async {
            self.progressController.allBordersStatusInitial()
        }
        
    }
    
    func changeCellStatusDone(cellIndex: Int) {
        DispatchQueue.main.async {
            self.progressController.changeCellStatusDone(cellIndex: cellIndex)
        }
    }

    func addReviewImages () {
        
        self.inputImages.removeFirst()
        self.reviewViewController.refImage = self.refImage
        self.reviewViewController.inputImages = self.inputImages
        self.reviewViewController.addReviewImages()
        
        // Reset
        self.refImage = nil
        self.imageListReference = []
        self.inputImages = []
        
        // Reset borders in progress view
        self.changeCellStatusInitial()
    }
}

extension UINavigationController {
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}


