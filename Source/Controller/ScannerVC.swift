//
//  ScannerVC.swift
//  ScanAnyQR
//
//  Created by Shreedharshan on 07/09/23.
//

import UIKit
import AVFoundation

public class ScannerVC: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    var scannerView = ScannerView()
    public var callback: ((UIImage?,String?)->())?

    
    private lazy var defaultDevice: AVCaptureDevice? = {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        return nil
    }()
    


    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrcodeFrameView = UIView()
     
    private let photoOutput = AVCapturePhotoOutput()
    
    var isCapturing = false
    
    var capturedImage: UIImage?

    
    public override func viewDidLoad() {
        super.viewDidLoad()
    
        setupViews()
        openCamera()
        captureSession.addOutput(photoOutput)


    }
    
    func setupViews() {
        
        self.scannerView.setupViews(self.view)
    
    }
    
}

//MARK: CAMERA AND SCANNER

extension ScannerVC {
    
     private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupScanner()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    print("The user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupScanner()
                    }
                } else {
                    self.handleDismiss("The user has not granted to access the camera")
                }
            }
            
        case .denied:
            print("The user has denied previously to access the camera.")
            self.handleDismiss("The user has denied previously to access the camera.")
            
        case .restricted:
            print("The user can't give camera access due to some restriction.")
            self.handleDismiss("The user can't give camera access due to some restriction.")
            
        default:
            print("Something has wrong due to we can't access the camera.")
            self.handleDismiss("Something has wrong due to we can't access the camera.")
        }
        
    }
        
        private func setupScanner() {
            guard let captureDevice = defaultDevice else {
                print("Failed to get the camera device")
                return
            }
            
            do {
                
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                if (captureSession.canAddInput(input)) {
                            captureSession.addInput(input)
                        } else {
                            print("CANT ADD")
                            return
                        }
                
                
                let captureMetaDataOutput = AVCaptureMetadataOutput()
                if captureSession.canAddOutput(captureMetaDataOutput) {
                    captureSession.addOutput(captureMetaDataOutput)
                } else {
                    print("CANT ADD")
                }
                
                
                
                captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                            captureMetaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
//                captureMetaDataOutput.metadataObjectTypes = supportedCodeTypes
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                scannerView.cameraView.layer.addSublayer(videoPreviewLayer!)
                
                captureSession.startRunning()
                
                
                    
                    qrcodeFrameView.layer.borderColor = UIColor.yellow.cgColor
                    qrcodeFrameView.layer.borderWidth = 2
                    scannerView.cameraView.addSubview(qrcodeFrameView)
                    scannerView.cameraView.bringSubview(toFront: qrcodeFrameView)
                
                
                
            } catch {
                print(error)
                return
            }
            
        }
    
    @objc func handleDismiss(_ msg: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okBtn)
            self.present(alert, animated: true)
        }
    }
    
}


// MARK: AV CAPTURE  METADATA DELEGATES

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrcodeFrameView.frame = CGRect.zero
            return
        }
        var metadataObj: AVMetadataObject?
        metadataObj = metadataObjects[0]
        
        if metadataObj?.type == AVMetadataObject.ObjectType.qr {
            let barcodeObjc = videoPreviewLayer?.transformedMetadataObject(for: metadataObj!)
            qrcodeFrameView.frame = barcodeObjc!.bounds
        
            if !isCapturing {
        
                isCapturing = true
                let ss = takeScreenshot()
                var str = String()
                
                let metadataObjc = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
                if metadataObjc.stringValue != nil {
                    str = metadataObjc.stringValue ?? ""
                }
                if ss != nil {
                    print("HERE")
                    self.callback?(ss,str)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("SOME ERROR")
                }
                
//                photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }
    }
}

func takeScreenshot() -> UIImage? {
   
    let window = UIApplication.shared.windows[0]  // Get the topmost window
        
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        for subview in window.subviews {
            subview.layer.render(in: context)
        }
        
        guard let capturedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return capturedImage
}


// MARK: AV CAPTURE  PHOTO DELEGATES

extension ScannerVC: AVCapturePhotoCaptureDelegate {

    private func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("ERROR HERRE",error)
        
//        guard let imageData = photo.fileDataRepresentation() else {
//            print("Error while generating image from photo capture data.");
//            return
//        }
//        guard let qrImage = UIImage(data: imageData) else {
//            print("Unable to generate UIImage from image data.");
//            return
//        }
//
//        captureSession.stopRunning()
//        self.capturedImage = qrImage
//        if isCapturing == true {
//            isCapturing = false
//            let vc = CapturedQRVC()
//            vc.capturedImage = self.capturedImage
//            self.navigationController?.pushViewController(vc, animated: true)
            
            
//            if let error = error {
//                            print(error.localizedDescription)
//                        }
//
//                        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
//                          print("image: \(UIImage(data: dataImage)?.size)") // Your Image
//                        }
            
//        }
    }
}



extension String {
    func verifyUrl () -> Bool {
        if let url = NSURL(string: self) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
}
