//
//  ViewController.swift
//  QRCode
//
//  Created by Hell Yeah on 2023-06-24.
//

import UIKit
import CoreImage
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var QRCodeImage: UIImageView!
    @IBOutlet weak var code: UILabel!
    
    @IBAction func generateCode(_ sender: UIButton) {
        let randomNumber = Int.random(in: 100000...999999)
        code.text = "\(randomNumber)"
        let data = "\(randomNumber)".data(using: .ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }
        filter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter.outputImage else { return }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        let scaleImage = ciImage.transformed(by: transform)
        QRCodeImage.image = UIImage(ciImage: scaleImage)
    }

    // MARK: Capture
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var scanResualt: UILabel!
    
    @IBAction func scanQRCode(_ sender: Any) {
        let scannerVC = ScannerViewController()
        scannerVC.delegate = self
        present(scannerVC, animated: true)
    }
}


extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func captureQRCode() {
        let captureDevice = AVCaptureDevice.default(for: .video)

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession.addInput(input)

            let captureMetaDataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetaDataOutput)

            captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            captureSession.startRunning()
        } catch {
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            DispatchQueue.main.async {
                self.scanResualt.text = stringValue
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}
