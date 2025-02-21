# ``ImageClassification_CNN_iOS``

iOS에서 CNN모델을 활용하여 물체를 감지하는 '객체 탐지 어플리케이션' 입니다.

## Overview
@TabNavigator {
    @Tab("실시간 탐지 모드") {
        ![실시간 탐지 모드](overview-1.png)
    }
    
    @Tab("사진 탐지 모드") {
        ![사진 탐지 모드](overview-2.png)
    }
}


## Topics

### ViewController
- ``CameraViewController``
- ``ImageViewController``

### Delegate
- ``AppDelegate``
- ``VideoCaptureDelegate``
- ``MeasureMentDelegate``
