import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    enum Mode {
        case albumCover
        case barcode
    }
    
    let mode: Mode
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var camera: CameraController
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingBarcodeResult = false
    @State private var scannedBarcode: String?
    @State private var showingAlbumInput = false
    
    init(mode: Mode) {
        self.mode = mode
        let controller = CameraController(mode: mode)
        self._camera = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        ZStack {
            if camera.permissionGranted {
                CameraPreviewView(camera: camera)
                    .ignoresSafeArea()
                    .onAppear {
                        camera.setupCamera()
                    }
                
                VStack {
                    // 모드에 따른 안내 메시지
                    Text(mode == .albumCover ? "앨범 커버를 촬영해주세요" : "바코드를 스캔해주세요")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.top, 50)
                    
                    if mode == .barcode {
                        // 바코드 스캔 영역 표시
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 250, height: 100)
                            .background(Color.white.opacity(0.1))
                    } else {
                        // 앨범 커버 촬영 가이드
                        ZStack {
                            // 반투명 오버레이
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()
                            
                            // 정사각형 가이드
                            GeometryReader { geometry in
                                let size = min(geometry.size.width - 40, geometry.size.height - 200)
                                ZStack {
                                    // 투명한 정사각형 영역
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: size, height: size)
                                        .background(Color.black.opacity(0.5))
                                        .mask(
                                            Rectangle()
                                                .fill(Color.black)
                                                .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
                                                .overlay(
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(width: size, height: size)
                                                )
                                        )
                                    
                                    // 가이드 라인
                                    Rectangle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: size, height: size)
                                    
                                    // 모서리 표시
                                    ForEach(0..<4) { index in
                                        let angle = Double(index) * 90
                                        let xOffset = size / 2 * (index % 2 == 0 ? -1 : 1)
                                        let yOffset = size / 2 * (index < 2 ? -1 : 1)
                                        
                                        Path { path in
                                            path.move(to: CGPoint(x: -20, y: 0))
                                            path.addLine(to: CGPoint(x: 20, y: 0))
                                            path.move(to: CGPoint(x: 0, y: -20))
                                            path.addLine(to: CGPoint(x: 0, y: 20))
                                        }
                                        .stroke(Color.white, lineWidth: 2)
                                        .rotationEffect(.degrees(angle))
                                        .offset(x: xOffset, y: yOffset)
                                    }
                                }
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 60) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            if mode == .albumCover {
                                camera.capturePhoto()
                            } else {
                                // 바코드 모드에서는 더미 바코드로 진행
                                let dummyBarcode = camera.lastScannedBarcode ?? "123456789"
                                scannedBarcode = dummyBarcode
                                showingBarcodeResult = true
                            }
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.2), lineWidth: 2)
                                        .frame(width: 60, height: 60)
                                )
                        }
                        .disabled(!camera.isReady)
                        
                        Button(action: {
                            camera.switchCamera()
                        }) {
                            Image(systemName: "camera.rotate.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .disabled(!camera.isReady)
                    }
                    .padding(.bottom, 30)
                }
            } else {
                VStack {
                    Text("카메라 접근 권한이 필요합니다")
                        .font(.headline)
                    Text("설정에서 카메라 접근을 허용해주세요")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    Button("설정으로 이동") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding(.top, 16)
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("오류"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .fullScreenCover(isPresented: $showingBarcodeResult) {
            BarcodeResultView(barcode: scannedBarcode ?? "")
        }
        .onChange(of: camera.capturedImage) { _, newImage in
            if let _ = newImage {
                showingAlbumInput = true
            }
        }
        .fullScreenCover(isPresented: $showingAlbumInput) {
            if let image = camera.capturedImage {
                NavigationView {
                    AlbumInputView(coverImage: image)
                }
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}

class CameraController: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var permissionGranted = false
    @Published var isReady = false
    @Published var lastScannedBarcode: String?
    @Published var capturedImage: UIImage?
    
    let photoOutput = AVCapturePhotoOutput()
    let metadataOutput = AVCaptureMetadataOutput()
    var position: AVCaptureDevice.Position = .back
    var mode: CameraView.Mode
    private var isConfigured = false
    
    init(mode: CameraView.Mode) {
        self.mode = mode
        super.init()
        
        // 백그라운드 알림 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleResume),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cleanupSession()
    }
    
    private func cleanupSession() {
        if session.isRunning {
            session.stopRunning()
        }
        
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        isConfigured = false
        isReady = false
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.cleanupSession()
        }
    }
    
    @objc private func handleInterruption() {
        stopSession()
    }
    
    @objc private func handleResume() {
        if permissionGranted && !isConfigured {
            setupCamera()
        }
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        default:
            permissionGranted = false
        }
    }
    
    func setupCamera() {
        guard permissionGranted && !isConfigured else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            // 기존 입출력 제거
            self.cleanupSession()
            
            do {
                // 카메라 입력 설정
                guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.position) else {
                    throw NSError(domain: "CameraError", code: -1, userInfo: [NSLocalizedDescriptionKey: "카메라를 찾을 수 없습니다."])
                }
                
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }
                
                // 사진 출력 설정
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                // 바코드 모드일 경우 메타데이터 출력 설정
                if self.mode == .barcode {
                    if self.session.canAddOutput(self.metadataOutput) {
                        self.session.addOutput(self.metadataOutput)
                        self.metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce]
                        self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    }
                }
                
                self.session.commitConfiguration()
                self.isConfigured = true
                
                DispatchQueue.main.async {
                    self.isReady = true
                    if !self.session.isRunning {
                        self.session.startRunning()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isReady = false
                    print("카메라 설정 오류: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func capturePhoto() {
        guard isReady else {
            print("카메라가 준비되지 않았습니다")
            self.capturedImage = UIImage(systemName: "music.note")
            return
        }
        
        guard session.isRunning else {
            print("카메라 세션이 실행중이지 않습니다")
            self.capturedImage = UIImage(systemName: "music.note")
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        // 메인 스레드에서 실행
        DispatchQueue.main.async {
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func switchCamera() {
        position = position == .back ? .front : .back
        setupCamera()
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("사진 촬영 오류: \(error.localizedDescription)")
                self.capturedImage = UIImage(systemName: "music.note")
                return
            }
            
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                self.capturedImage = UIImage(systemName: "music.note")
                return
            }
            
            self.capturedImage = image
        }
    }
}

extension CameraController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lastScannedBarcode = stringValue
            
            // 바코드 인식 시 햅틱 피드백 제공
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var camera: CameraController
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        // 기존 레이어 제거
        view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
            
            // 세션이 다른 경우 업데이트
            if previewLayer.session != camera.session {
                previewLayer.session = camera.session
            }
        }
    }
} 