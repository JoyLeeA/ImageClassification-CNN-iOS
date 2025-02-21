//
//  CameraViewController.swift
//  ImageClassification-CNN-iOS
//
//  Created by 이종하 on 10/5/24.
//  Copyright © 2024 JoyLee. All rights reserved.
//

import UIKit
import Vision
import SnapKit

final class CameraViewController: UIViewController {
    private let videoPreview: UIView = UIView()
    private let mesureView: UIView = UIView()
    private let labelView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    private let topLabelView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.blue.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    private let informationView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    private let objectLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let confidenceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        return label
    }()
    private let toplabelLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.layer.borderColor = UIColor.gray.cgColor
        label.layer.borderWidth = 1.5
        label.isUserInteractionEnabled = true
        return label
    }()
    private let top1Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    private let top5Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    private let inferenceLabel: UILabel = UILabel()
    private let etimeLabel: UILabel = UILabel()
    private let fpsLabel: UILabel = UILabel()
    private let memoryLabel: UILabel = UILabel()
    private lazy var modelNameLabel: UILabel = {
        let label = UILabel()
        label.text = "model: MobileNetV3"
        return label
    }()
    private let modeToggleButton: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        return toggle
    }()
    private var pickerResult: String? = "monitor"
    private var memoryBeforeInference: UInt64 = 0
    private var memoryAfterInference: UInt64 = 0

    private let measureMent = MeasureMent()
    private let memoryUsageMonitor = MemoryUsageMonitor()
    private let classificationModel = mobilenetV3_large()

    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    var videoCapture: VideoCapture!

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        bind()
        setUpModel()
        setUpCamera()
        measureMent.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }

    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: classificationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(
                model: visionModel,
                completionHandler: visionRequestDidComplete
            )
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError()
        }
    }

    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: .vga640x480) { success in

            if success {
                if let previewLayer = self.videoCapture.previewLayer {
                    previewLayer.videoGravity = .resizeAspectFill
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                self.videoCapture.start()
            }
        }
    }

    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }

    func render() {
        view.addSubview(mesureView)
        mesureView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(200)
        }

        view.addSubview(videoPreview)
        videoPreview.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(mesureView.snp.top)
        }

        mesureView.addSubview(labelView)
        labelView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(30)
        }

        labelView.addSubview(objectLabel)
        objectLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2)
            $0.centerY.equalToSuperview()
        }

        labelView.addSubview(confidenceLabel)
        confidenceLabel.snp.makeConstraints {
            $0.leading.equalTo(objectLabel.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }

        mesureView.addSubview(topLabelView)
        topLabelView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(labelView.snp.bottom).offset(2)
            $0.height.equalTo(60)
        }

        topLabelView.addSubview(toplabelLabel)
        toplabelLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(130)
        }

        topLabelView.addSubview(top1Label)
        top1Label.snp.makeConstraints {
            $0.leading.equalTo(toplabelLabel.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.top.equalToSuperview().offset(5)
        }

        topLabelView.addSubview(top5Label)
        top5Label.snp.makeConstraints {
            $0.leading.equalTo(toplabelLabel.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.top.equalTo(top1Label.snp.bottom).offset(1)
            $0.width.equalTo(400)
        }

        mesureView.addSubview(informationView)
        informationView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(topLabelView.snp.bottom).offset(2)
        }

        informationView.addSubview(inferenceLabel)
        inferenceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2)
            $0.top.equalToSuperview().offset(1)
        }

        informationView.addSubview(etimeLabel)
        etimeLabel.snp.makeConstraints {
            $0.leading.equalTo(inferenceLabel.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(1)
        }

        informationView.addSubview(fpsLabel)
        fpsLabel.snp.makeConstraints {
            $0.leading.equalTo(etimeLabel.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(1)
        }

        informationView.addSubview(memoryLabel)
        memoryLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2)
            $0.top.equalTo(inferenceLabel.snp.bottom).offset(2)
        }

        informationView.addSubview(modeToggleButton)
        modeToggleButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-20)
        }

        informationView.addSubview(modelNameLabel)
        modelNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2)
            $0.top.equalTo(memoryLabel.snp.bottom).offset(2)
        }
    }

    func bind() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(labelTapped))
        toplabelLabel.addGestureRecognizer(tapGesture)

        modeToggleButton.addTarget(
            self,
            action: #selector(switchValueChanged(_:)),
            for: .valueChanged)

    }

    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            if let window = UIApplication.shared.windows.first {
                let imageViewController = ImageViewController()
                window.rootViewController = imageViewController
                window.makeKeyAndVisible()
            }
        }
    }

    @objc func labelTapped() {
        let labelPicker = LabelPicker()
        labelPicker.didSelectLabel = { [weak self] selectedLabel in
            self?.pickerResult = selectedLabel
            self?.toplabelLabel.text = selectedLabel
        }
        present(labelPicker, animated: true)
    }
}

extension CameraViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?) {
        if let pixelBuffer = pixelBuffer {
            // start of measure
            self.measureMent.startCamera()

            // start predict
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}

extension CameraViewController {
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        startInference()

        guard
            let request = request
        else {
            fatalError()
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])

        DispatchQueue.main.sync {
            memoryLabel.text = endInference()
        }
    }

    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        self.measureMent.labeling(for: 0, with: "endInference")

        if let classificationResults = request.results as? [VNClassificationObservation] {
            calculateAccuracy(results: classificationResults)
        } else if let mlFeatureValueResults = request.results as? [VNCoreMLFeatureValueObservation] {
            showCustomResult(results: mlFeatureValueResults)
        }

        DispatchQueue.main.sync {
            self.measureMent.stopCamera()
        }
    }

    func startInference() {
        memoryBeforeInference = memoryUsageMonitor.reportMemoryUsage()
    }

    func endInference() -> String {
        memoryAfterInference = memoryUsageMonitor.reportMemoryUsage()

        let memoryUsedForInference: UInt64

        if memoryAfterInference >= memoryBeforeInference {
            memoryUsedForInference = memoryAfterInference - memoryBeforeInference
        } else {
            memoryUsedForInference = UInt64(0.3)
        }
        return "memory: \(memoryUsageMonitor.bytesToMB(bytes: memoryUsedForInference * 100))"
    }
}

extension CameraViewController: MeasureMentDelegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        self.inferenceLabel.text = "inference: \(Int(inferenceTime * 1000.0)) mm"
        self.etimeLabel.text = "execution: \(Int(executionTime * 1000.0)) mm"
        self.fpsLabel.text = "fps: \(fps)"

    }

    /// 카메라로 인식한 물체가 어떤 물체인지에 대한 결과 값을 계산하는 함수 입니다.
    func calculateAccuracy(results: [VNClassificationObservation]) {
        guard let top1Result = results.first else {
            showFailResult()
            return
        }

        let top5Results = results.prefix(5)
        let groundTruthLabel = pickerResult

        let top1Correct = top1Result.identifier == groundTruthLabel
        let top5Correct = top5Results.contains { $0.identifier == groundTruthLabel }

        DispatchQueue.main.sync {
            self.toplabelLabel.text = (groundTruthLabel ?? "monitor")
            self.objectLabel.text = top1Result.identifier
            self.confidenceLabel.text = "\(round(top1Result.confidence * 100))%"

            if top1Correct {
                self.top1Label.text = "Top-1: \(top1Result.identifier) \(round(top1Result.confidence * 100))%"
            } else {
                self.top1Label.text = "Top-1: Incorrect"
            }

            let top5Text = top5Results.map { result in
                return "\(result.identifier) \(round(result.confidence * 100))%"
            }.joined(separator: "\n")

            if top5Correct {
                self.top5Label.text = "Top-5: Correct\n\(top5Text)"
            } else {
                self.top5Label.text = "Top-5: Incorrect\n\(top5Text)"
            }
        }
    }

}

extension CameraViewController {
    func showClassificationResult(results: [VNClassificationObservation]) {
        guard let result = results.first else {
            showFailResult()
            return
        }

        showResults(objectLabel: result.identifier, confidence: result.confidence)
    }

    func showCustomResult(results: [VNCoreMLFeatureValueObservation]) {
        guard
            let result = results.first
        else {
            showFailResult()
            return
        }
        showFailResult()
    }

    func showFailResult() {
        DispatchQueue.main.sync {
            self.objectLabel.text = "n/a result"
            self.confidenceLabel.text = "-- %"
        }
    }

    func showResults(objectLabel: String, confidence: VNConfidence) {
        DispatchQueue.main.sync {
            self.objectLabel.text = objectLabel
            self.confidenceLabel.text = "\(round(confidence * 100)) %"
        }
    }
}
