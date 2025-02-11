//
//  ImageViewController.swift
//  ImageClassification-CNN-iOS
//
//  Created by 이종하 on 10/5/24.
//  Copyright © 2024 JoyLee. All rights reserved.
//

import UIKit
import Vision

@available(iOS 13.0, *)
class ImageViewController: UIViewController {
    // MARK: - UI Properties
    
    private let imagePreview: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private let mesureView: UIView = UIView()
    private let imageSelectView: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.setTitle("이미지 선택", for: .normal)
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.red.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.3)
        return button
    }()
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
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        return label
    }()
    private let top5Label: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        return label
    }()
    
    private let inferenceLabel: UILabel = UILabel()
    private let etimeLabel: UILabel = UILabel()
    private let fpsLabel: UILabel = UILabel()
    private let memoryLabel: UILabel = UILabel()
    private let modelNameLabel: UILabel = UILabel()
    private let modelOptimizerLabel: UILabel = UILabel()
    private let modelepochsLabel: UILabel = UILabel()
    private let modelBatchLabel: UILabel = UILabel()
    private let modeToggleButton: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        return toggle
    }()
    private var pickerResult: String? = "monitor"
    private var memoryBeforeInference: UInt64 = 0
    private var memoryAfterInference: UInt64 = 0

    private let measureMent = MeasureMent()
    private let memoryUsageMonitor = MemoryUsageMonitor()
    let imagePickerController = UIImagePickerController()
    let classificationModel = mobilenetV3_large()

    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        bind()
        setUpModel()
        imagePickerController.delegate = self
        measureMent.delegate = self
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        print("button clicked")
        self.present(imagePickerController, animated: true)
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: classificationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError()
        }
    }
    
    func render() {
        view.addSubview(mesureView)
        mesureView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        view.addSubview(imagePreview)
        imagePreview.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(mesureView.snp.top)
        }
        
        imagePreview.addSubview(imageSelectView)
        imageSelectView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(100)
        }
        
        imageSelectView.addTarget(
            self,
            action: #selector(buttonClicked(_:)),
            for: .touchUpInside)
        
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
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(labelView.snp.bottom).offset(2)
            $0.height.equalTo(60)
        }
        
        topLabelView.addSubview(toplabelLabel)
        toplabelLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(2)
            $0.centerY.equalToSuperview()
        }
        topLabelView.addSubview(top1Label)
        top1Label.snp.makeConstraints {
            $0.leading.equalTo(toplabelLabel.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(1)
        }
        topLabelView.addSubview(top5Label)
        top5Label.snp.makeConstraints {
            $0.leading.equalTo(toplabelLabel.snp.trailing).offset(10)
            $0.top.equalTo(top1Label.snp.bottom).offset(1)
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
              print("Switch is ON")
          } else {
              print("Switch is OFF")
              if let window = UIApplication.shared.windows.first {
                  let cameraViewController = CameraViewController()
                  window.rootViewController = cameraViewController
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

extension ImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
           let url = info[UIImagePickerControllerImageURL] as? URL {
            imagePreview.image = image
            self.predict(with: url)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ImageViewController {
    func predict(with url: URL) {
        startInference()

        guard
            let request = request
        else {
            fatalError()
        }
        let handler = VNImageRequestHandler(url: url, options: [:])
        try? handler.perform([request])
        memoryLabel.text = endInference() // 추론 종료 후
    }

    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        if let classificationResults = request.results as? [VNClassificationObservation] {
            calculateAccuracy(results: classificationResults)
        } else if let mlFeatureValueResults = request.results as? [VNCoreMLFeatureValueObservation] {
            showCustomResult(results: mlFeatureValueResults)
        }
        self.measureMent.stopImage()
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
        return "memory: \(memoryUsageMonitor.bytesToMB(bytes: memoryUsedForInference))"
    }
}

extension ImageViewController: MeasureMentDelegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        self.inferenceLabel.text = "inference: \(Int(inferenceTime * 1000.0)) mm"
        self.etimeLabel.text = "execution: \(Int(executionTime * 1000.0)) mm"
        self.fpsLabel.text = "fps: \(fps)"

    }

    func calculateAccuracy(results: [VNClassificationObservation]) {
        guard
            let top1Result = results.first
        else {
            showFailResult()
            return
        }

        // Top-1 결과 표시
        showResults(objectLabel: top1Result.identifier, confidence: top1Result.confidence)

        // Top-5 결과 추출
        let top5Results = results.prefix(5)

        // 실제 레이블과 비교하여 정확도 계산 (여기서는 예시로 "정답" 클래스를 직접 정의, 실제 데이터셋에 따라 다름)
        let groundTruthLabel = pickerResult // 실제 정답 레이블

        // Top-1이 정답과 일치하는지 확인
        let top1Correct = top1Result.identifier == groundTruthLabel

        // Top-5 중 정답이 있는지 확인
        let top5Correct = top5Results.contains { $0.identifier == groundTruthLabel }


            self.toplabelLabel.text = (groundTruthLabel ?? "monitor") + ":"
            // UI에 Top-1 및 Top-5 결과 표시 (원하는 대로 커스터마이징 가능)
            if top1Correct {
                self.top1Label.text = "Top-1: \(round(top1Result.confidence * 100))%"
            } else {
                self.top1Label.text = "Top-1: Incorrect"
            }

            // Top-5 결과 문자열 생성
            let top5Text = top5Results.map { result in
                return "\(result.identifier) \(round(result.confidence * 100))%"
            }.joined(separator: "\n")

            if top5Correct {
                self.top5Label.text = "Top-5: Correct"
            } else {
                self.top5Label.text = "Top-5: Incorrect"
            }

    }
}

extension ImageViewController {
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
        showFailResult() // TODO
    }

    func showFailResult() {
        DispatchQueue.main.sync {
            self.objectLabel.text = "n/a result"
            self.confidenceLabel.text = "-- %"
        }
    }

    func showResults(objectLabel: String, confidence: VNConfidence) {
        self.objectLabel.text = objectLabel
        self.confidenceLabel.text = "\(round(confidence * 100)) %"
    }
}
