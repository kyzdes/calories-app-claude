import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scannedCode: String?
    @State private var isSearching = false
    @State private var foundProduct: Product?
    @State private var showNotFound = false
    @State private var torchOn = false
    @State private var cameraPermissionDenied = false

    let onProductFound: (Product) -> Void
    let onCreateProduct: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                if cameraPermissionDenied {
                    permissionDeniedView
                } else {
                    // Camera preview
                    CameraPreview(
                        onBarcodeDetected: { code in
                            handleBarcode(code)
                        },
                        torchOn: torchOn
                    )
                    .ignoresSafeArea()

                    // Overlay
                    scannerOverlay
                }
            }
            .navigationTitle("Сканер")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear {
                checkCameraPermission()
            }
            .alert("Продукт не найден", isPresented: $showNotFound) {
                Button("Создать продукт") {
                    if let code = scannedCode {
                        onCreateProduct(code)
                    }
                    dismiss()
                }
                Button("Сканировать ещё раз") {
                    scannedCode = nil
                }
                Button("Отмена", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Этого продукта нет в базе. Хотите создать его?")
            }
        }
    }

    // MARK: - Scanner Overlay

    private var scannerOverlay: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            // Viewfinder cutout
            VStack {
                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 250, height: 150)
                    .background(Color.clear)

                if isSearching {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 16)
                } else {
                    Text("Наведите на штрих-код")
                        .font(.cmBody)
                        .foregroundStyle(.white)
                        .padding(.top, 16)
                }

                Spacer()

                Button {
                    torchOn.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        Text(torchOn ? "Выключить фонарик" : "Включить фонарик")
                    }
                    .font(.cmBody)
                    .foregroundStyle(.white)
                }
                .padding(.bottom, 40)
            }
        }
        // Allow taps to pass through the viewfinder area
        .allowsHitTesting(true)
    }

    // MARK: - Permission Denied

    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.cmTextTertiary)

            Text("Нет доступа к камере")
                .font(.cmH2)
                .foregroundStyle(Color.cmTextPrimary)

            Text("Разрешите доступ к камере\nв настройках для сканирования\nштрих-кодов")
                .font(.cmBody)
                .foregroundStyle(Color.cmTextSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Открыть настройки") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Logic

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    cameraPermissionDenied = !granted
                }
            }
        default:
            cameraPermissionDenied = true
        }
    }

    private func handleBarcode(_ code: String) {
        guard scannedCode == nil, !isSearching else { return }
        scannedCode = code
        isSearching = true

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        Task {
            do {
                if let product = try await OpenFoodFactsService.searchByBarcode(code) {
                    await MainActor.run {
                        isSearching = false
                        onProductFound(product)
                        dismiss()
                    }
                } else {
                    await MainActor.run {
                        isSearching = false
                        showNotFound = true
                    }
                }
            } catch {
                await MainActor.run {
                    isSearching = false
                    showNotFound = true
                }
            }
        }
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

private struct CameraPreview: UIViewRepresentable {
    let onBarcodeDetected: (String) -> Void
    let torchOn: Bool

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView(onBarcodeDetected: onBarcodeDetected)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.setTorch(torchOn)
    }
}

private class CameraPreviewUIView: UIView {
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let onBarcodeDetected: (String) -> Void
    private let metadataOutput = AVCaptureMetadataOutput()

    init(onBarcodeDetected: @escaping (String) -> Void) {
        self.onBarcodeDetected = onBarcodeDetected
        super.init(frame: .zero)
        setupCamera()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(Coordinator(onDetected: onBarcodeDetected), queue: .main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce, .code128]
        }

        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        previewLayer = layer

        Task.detached {
            self.captureSession.startRunning()
        }
    }

    private class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onDetected: (String) -> Void

        init(onDetected: @escaping (String) -> Void) {
            self.onDetected = onDetected
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = object.stringValue else { return }
            onDetected(value)
        }
    }
}
