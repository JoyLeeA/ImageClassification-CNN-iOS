//
//  Measure.swift
//  ImageClassification-CNN-iOS
//
//  Created by 이종하 on 10/5/24.
//  Copyright © 2024 JoyLee. All rights reserved.
//

import UIKit

protocol MeasureMentDelegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int)
}

final class MeasureMent {
    var delegate: MeasureMentDelegate?
    var index: Int = 0
    var measurements: [Dictionary<String, Double>]

    init() {
        let measurement = [
            "start": CACurrentMediaTime(),
            "end": CACurrentMediaTime()
        ]
        measurements = Array<Dictionary<String, Double>>(repeating: measurement, count: 30)
    }

    func startCamera() {
        index = (index + 1) % 30
        measurements[index] = [:]
        labeling(for: index, with: "start")
    }

    func stopCamera() {
        labeling(for: index, with: "end")
        let beforeMeasurement = getBeforeMeasurment(for: index)
        let currentMeasurement = measurements[index]
        guard
            let startTime = currentMeasurement["start"],
            let endInferenceTime = currentMeasurement["endInference"],
            let endTime = currentMeasurement["end"],
            let beforeStartTime = beforeMeasurement["start"]
        else {
            return
        }
        delegate?.updateMeasure(inferenceTime: endInferenceTime - startTime,
                                executionTime: endTime - startTime,
                                fps: Int(1 / (startTime - beforeStartTime)))
    }

    func stopImage() {
        labeling(for: index, with: "endInference")

        let beforeMeasurement = getBeforeMeasurment(for: index)
        let currentMeasurement = measurements[index]

        guard
            let startTime = currentMeasurement["start"],
            let endInferenceTime = currentMeasurement["endInference"],
            let endTime = currentMeasurement["end"],
            let beforeStartTime = beforeMeasurement["start"]
        else {
            return
        }

        let timeDifference = startTime - beforeStartTime

        // timeDifference가 0이거나 매우 작은 값을 가지는 경우를 처리
        if timeDifference > 0 {
            let fps = Int(1 / timeDifference)
            delegate?.updateMeasure(inferenceTime: endInferenceTime - startTime,
                                    executionTime: endTime - startTime,
                                    fps: fps)
        } else {
            // timeDifference가 0이거나 음수일 경우, FPS 값을 0 또는 기본값으로 설정
            delegate?.updateMeasure(inferenceTime: endInferenceTime - startTime,
                                    executionTime: endTime - startTime,
                                    fps: 0) // 기본값 0 또는 다른 값으로 설정
        }
    }

    func labeling(for index: Int, with msg: String? = "") {
        if let message = msg {
            // 인덱스가 배열 크기보다 큰지 확인
            guard index < measurements.count else {
                print("Index out of range")
                return
            }
            measurements[index][message] = CACurrentMediaTime()
        }
    }

    private func getBeforeMeasurment(for index: Int) -> Dictionary<String, Double> {
        return measurements[(index + 30 - 1) % 30] // 인덱스를 안전하게 계산
    }
}
