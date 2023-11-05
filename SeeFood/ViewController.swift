//
//  ViewController.swift
//  SeeFood
//
//  Created by Shazeen Thowfeek on 04/11/2023.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    // ... your existing code ...
    @IBOutlet weak var imageView: UIImageView!
      
      let imagePicker = UIImagePickerController()
    
    // AVCaptureSession instance
    let captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        // ... your existing code ...
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary //.camera
                imagePicker.allowsEditing = false
        // Configure AVCaptureSession
        configureCaptureSession()
    }

    // ... your existing code ...
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedimage
            guard let ciimage = CIImage(image: userPickedimage)else {
                fatalError("could not convert ui image to ci image")
            }
           detect(image: ciimage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }

    // MARK: AVCaptureSession Configuration
    func configureCaptureSession() {
        // Set up video input
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if captureSession.canAddInput(videoDeviceInput) {
                    captureSession.addInput(videoDeviceInput)
                }
            } catch {
                print("Error adding video input: \(error)")
            }
        } else {
            print("No video device found")
        }

        // Set up video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        DispatchQueue.global(qos: .userInteractive).async {
                self.captureSession.startRunning()
            }
        
    }

    // AVCaptureVideoDataOutputSampleBufferDelegate method
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process the video frames here
        // You can use Vision framework for image analysis or Core ML for machine learning tasks
    }
    
    // ... your existing code ...
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for:MobileNetV2().model) else {
            fatalError("Loading coreML model failed")
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("model failed to process image")
            }
            if let firstResult = results.first{
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "HotDog!"
                }else{
                    self.navigationItem.title = "Not hotdog"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
           
           present(imagePicker, animated: true, completion: nil)
       }
    // Start the capture session
    
       
}
