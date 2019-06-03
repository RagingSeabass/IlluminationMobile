//
//  ReviewViewController.swift
//  IlluminationMobile
//
//  Created by Christian Schmidt on 14/05/2019.
//  Copyright © 2019 Christian Schmidt. All rights reserved.
//

import UIKit
import Alamofire

class ReviewViewController: UIViewController {
    
    let screenSize: CGRect = UIScreen.main.bounds
    var refImage: UIImage? = nil
    var inputImages: [UIImage] = []
    @IBOutlet weak var topText: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var buttonView: UIView!
    var uploadButton: UIButton? = nil
    var cancelButton: UIButton? = nil
    
    @IBOutlet weak var cellOne: UIImageView!
    @IBOutlet weak var cellTwo: UIImageView!
    @IBOutlet weak var cellThree: UIImageView!
    @IBOutlet weak var cellFour: UIImageView!
    @IBOutlet weak var cellFive: UIImageView!
    
    // Synchronization
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "queue")
    let semaphore = DispatchSemaphore(value: 0)
    
    var accessToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisuals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        uploadButton!.setTitle("Upload", for: .normal)
        uploadButton!.backgroundColor = UIColor(red: 123/255, green: 58/255, blue: 228/255, alpha: 1)
    }
    
    func uploadImagesCompletiion() {
        print("Uploading done")
        uploadButton!.setTitle("Success", for: .normal)
        uploadButton!.backgroundColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1)
        sleep(2)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setupVisuals() {
        setupViews()
        addBackgroundColor()
        addCornerRadius()
        addButtons()
    }
    
    func setupViews() {
        //scrollView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        self.scrollView.isDirectionalLockEnabled = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    func addBackgroundColor() {
        let bg_color = UIColor(red: 24/255, green: 26/255, blue: 28/255, alpha: 1)
        
        // Setup cells
        cellOne.backgroundColor = bg_color
        cellTwo.backgroundColor = bg_color
        cellThree.backgroundColor = bg_color
        cellFour.backgroundColor = bg_color
        cellFive.backgroundColor = bg_color
    }
    
    func addCornerRadius() {
        self.cellOne.layer.cornerRadius = 12
        self.cellTwo.layer.cornerRadius = 12
        self.cellThree.layer.cornerRadius = 12
        self.cellFour.layer.cornerRadius = 12
        self.cellFive.layer.cornerRadius = 12
    }
    
    func addReviewImages() {

        let ratio = self.refImage!.size.width / self.refImage!.size.height
        let width = stackView.frame.size.width - 40
        let height = width / ratio
        
        self.scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: height*CGFloat(self.inputImages.count+1)+CGFloat(self.inputImages.count)*20+100)
 
        // Reference image
        self.addImage(image: self.refImage!, index: 1, width: width, height: height)
        
        // Input images
        for index in 1...self.inputImages.count {
            let image = self.inputImages[index-1]
            self.addImage(image: image, index: index+1, width: width, height: height)
        }
        
        addCornerRadius()
    }
    
    func addButtons() {
       
        uploadButton = UIButton(frame: CGRect(x: 30, y: 10, width: 250, height: 60))
        uploadButton!.layer.cornerRadius = 30
        uploadButton!.backgroundColor = UIColor(red: 123/255, green: 58/255, blue: 228/255, alpha: 1)
        uploadButton!.setTitle("Upload", for: .normal)
        uploadButton!.titleLabel?.font = UIFont(name: "Futura", size: 20)
        uploadButton!.isUserInteractionEnabled = true
        uploadButton!.addTarget(self, action: #selector(self.uploadButtonPressed(_:)), for: .touchUpInside)
        uploadButton?.widthAnchor.constraint(equalToConstant: 250)
        uploadButton?.heightAnchor.constraint(equalToConstant: 60)
        
        self.buttonView.addSubview(uploadButton!)
        
        cancelButton = UIButton(frame: CGRect(x: 285, y: 10, width: 60, height: 60))
        cancelButton!.layer.cornerRadius = 30
        cancelButton!.backgroundColor = UIColor(red: 24/255, green: 26/255, blue: 28/255, alpha: 1)
        cancelButton!.setTitle("X", for: .normal)
        uploadButton!.titleLabel?.font = UIFont(name: "Futura", size: 20)
        cancelButton!.isUserInteractionEnabled = true
        cancelButton!.addTarget(self, action: #selector(self.cancelButtonPressed(_:)), for: .touchUpInside)
        cancelButton?.widthAnchor.constraint(equalToConstant: 60)
        cancelButton?.heightAnchor.constraint(equalToConstant: 60)
        
        self.buttonView.addSubview(cancelButton!)

    }
    
    func addImage(image: UIImage, index: Int, width: CGFloat, height: CGFloat) {
        var imageView: UIImageView? = nil
        
        switch index {
        case 1:
            imageView = self.cellOne!
        case 2:
            imageView = self.cellTwo!
        case 3:
            imageView = self.cellThree!
        case 4:
            imageView = self.cellFour!
        case 5:
            imageView = self.cellFive!
        default:
            print(index)
            print("addImage: Invalid Index")
        }
        
        let x = imageView!.frame.origin.x
        var y = CGFloat(index-1)*height
        if (index > 1) {
            y += CGFloat(index-1)*20
        }

        imageView!.image = image
        imageView!.frame = CGRect(
            x: x,
            y: y, width: width, height: height);
        
        imageView!.contentMode = UIImageView.ContentMode.scaleAspectFill
        imageView!.layer.masksToBounds = true
    }
    
    @objc func uploadButtonPressed(_ sender: UIButton) {
        self.uploadAllImages(completion: uploadImagesCompletiion)
    }
    
    @objc func cancelButtonPressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func uploadAllImages(completion: @escaping ()->()) {
        print("uploading")
        uploadButton!.setTitle("Uploading..", for: .normal)
        
        let uuid = NSUUID().uuidString
        let inFolder = "train/in/"
        let outFolder = "train/out/"
        self.queue.async {
            // Reference image
            let filenameRef = outFolder + uuid + ".png"
            self.uploadImage(filenameRemote: filenameRef, image: self.refImage!)
            self.semaphore.wait()
            // Input images
            for index in 0...(self.inputImages.count-1) {
                let filename = inFolder + uuid + "_" + String(index) + ".png"
                self.uploadImage(filenameRemote: filename, image: self.inputImages[index])
                self.semaphore.wait()
            }
        }
        
        // Wait for uploads to finish
        self.group.notify(queue: self.queue) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func uploadImage(filenameRemote: String, image: UIImage) {
        self.group.enter()
        self.getPresignedURL(accessToken: self.accessToken, filename: filenameRemote) { (presignedUrl, statusCode) in
            switch statusCode {
            case 200:
                self.uploadS3(presignedUrl: presignedUrl, image: image) { () in
                    self.semaphore.signal()
                    self.group.leave()
                }
            default:
                self.getAccessToken { (token) in
                    self.accessToken = token
                    self.getPresignedURL(accessToken: token, filename: filenameRemote) { (presignedUrl, statusCode) in
                        self.uploadS3(presignedUrl: presignedUrl, image: image) { () in
                            self.semaphore.signal()
                            self.group.leave()
                        }
                    }
                }
            }
        }
        
    }
    
    func getAccessToken(completion: @escaping (String)->()) {
        let headers: HTTPHeaders = []
        let body: [String: String] = [
            "username" : "illumination_user",
            "password" : "2e+P8t/fT8Hm{g.^6vX?D>2MB&32"
        ]
        
        let url = "http://134.209.165.154:5000/auth"
        let key = "access_token"
        
        postRequest(url: url, body: body, headers: headers, jsonKey: key) { (accessToken, statusCode) in
            completion(accessToken)
        }
    }
    
    func getPresignedURL(accessToken: String, filename: String, completion: @escaping (String, Int)->()) {
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + accessToken
        ]
        let body: [String: String] = [
            "filename" : filename
        ]
        
        let url = "http://134.209.165.154:5000/get-signed-url"
        let key = "presigned_url"
        
        postRequest(url: url, body: body, headers: headers, jsonKey: key) { (presignedUrl, statusCode) in
            completion(presignedUrl, statusCode)
        }
    }
    
    func uploadS3(presignedUrl: String, image: UIImage, completion: @escaping ()->()) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/octet-stream",
            "x-amz-acl": "private"
        ]
        
        let imgData = image.pngData()
        
        AF.upload(imgData!, to: presignedUrl, method: .put, headers: headers)
            .responseData{ response in
                print(response)
                completion()
        }
    }
    
    func postRequest(url: String, body: [String:String], headers: HTTPHeaders, jsonKey: String, completion: @escaping (String, Int)->()) {
        
        AF.request(url, method: HTTPMethod.post, parameters: body, encoding: JSONEncoding.default, headers: headers)
            .responseString { response in
                if let statusCode = response.response?.statusCode {
                    
                    switch statusCode {
                        
                        case 200:
                            if let data = response.data {
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                                        let respValue = json[jsonKey]!
                                        completion(respValue, statusCode)
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        
                        default:
                            print(statusCode)
                            print(response)
                            completion("", statusCode)
                    }
                    
                }
        }
    }
    
    
}

