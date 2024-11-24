//
//  ScanView.swift
//  Easy Scan
//
//  Created by zzh on 2024/11/23.
//

import SwiftUI

import AVFoundation
import UIKit

struct ScanView: View {
    @State private var scannedCode: String?
    @State private var isShowingScanner = false
    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

        VStack {
            if let code = scannedCode {
                Text("Scanned Code: \(code)")
            } else {
                Text("No QR code is scanned")
            }
            Button("Scan QR Code") {
                isShowingScanner = true
            }
            .sheet(isPresented: $isShowingScanner) {
                QRCodeScannerView(scannedCode: $scannedCode)
            }
        }
    }
}

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> QRScannerViewController {
        QRScannerViewController { code in
            scannedCode = code
            presentationMode.wrappedValue.dismiss()
        }
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var codeFoundHandler: (String) -> Void
    
    init(codeFoundHandler: @escaping (String) -> Void) {
        self.codeFoundHandler = codeFoundHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
//        captureSession.startRunning()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if let stringValue = metadataObject.stringValue {
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                    self.codeFoundHandler(stringValue)
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

#Preview {
    ScanView()
}
