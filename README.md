# 🎙️ Voice Memos — Signal Processing on Apple Platforms

[![Swift](https://img.shields.io/badge/Swift-6.2+-orange.svg?style=flat&logo=swift)](https://developer.apple.com/swift/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg?style=flat&logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![Framework](https://img.shields.io/badge/Framework-AVFoundation-red.svg?style=flat&logo=apple)](https://developer.apple.com/documentation/avfoundation/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018.0%2B%20%7C%20macOS%2015.0%2B-lightgrey.svg?style=flat&logo=apple)](https://developer.apple.com/apple-build-system/)

**Voice Memos** is a hands-on learning project focused on **building native iOS and macOS applications** alongside the practical study of **Digital Signal Processing (DSP)**.

The objective of the project is to evolve through incremental phases, exploring everything from low-level access to audio input hardware to advanced algorithms for real-time frequency analysis and audio manipulation.

---

## 🎯 Phase 1: Sound Intensity Analysis (Current Version)

In this first stage, the primary focus was establishing native audio recording and understanding **sound signal intensity measurement (amplitude/decibels)**.

### ✨ Key Features
* **📊 Real-Time Intensity Bar Chart:** An adaptive bar visualization that responds instantaneously to microphone volume fluctuations, allowing users to track peak and amplitude levels during recording.
* **🎙️ Hardware Audio Capture:** Direct integration with system audio resources for low-latency microphone input capturing across iOS and macOS.
* **📱 Desktop & Mobile UI:** A clean, responsive interface built entirely declaratively using SwiftUI.

---

## 🛠️ Technologies & Frameworks

* **[Swift](https://developer.apple.com/swift/):** Primary programming language used throughout the project.
* **[SwiftUI](https://developer.apple.com/xcode/swiftui/):** Declarative framework used for building reactive user interfaces and custom visual components (such as the real-time bar graph).
* **[AVFoundation](https://developer.apple.com/documentation/avfoundation/):** Essential Apple framework for audio capture, hardware management, and raw audio level monitoring (`AVAudioRecorder`, channel metering, and power levels).

---

## 🚀 Roadmap & Future Versions

The project will continue to be expanded in phases as signal processing concepts are further explored:

- [x] **Phase 1: Audio Capture & Intensity (Current)**
  - Native audio recording via AVFoundation.
  - Amplitude and sound intensity measurement.
  - Real-time bar graph visualization.

- [ ] **Phase 2: Spectrogram & Frequency Domain Analysis**
  - Implementation of Fast Fourier Transform (FFT) for signal decomposition.
  - Development of an interactive **spectrogram** (a time-frequency visual map or "photo" of the signal) to improve spectral understanding.

- [ ] **Phase 3: Signal Processing & Noise Reduction**
  - Application of digital audio filters (Low-pass, High-pass, Band-pass).
  - Implementation of noise reduction and cancellation algorithms.

---

## 💻 How to Run

1. Clone this repository:
```bash
   git clone [https://github.com/your-username/VoiceMemos.git](https://github.com/isaqueDaSilva/Voice-Memos.git)
```
2. Open the .xcodeproj file in Xcode (26.0+ recommended).
3. Select your target device:
    - iOS: Physical device recommended for microphone input testing (or simulator with audio passthrough).
    - macOS: Designed to run directly as a native Mac app.
4. Ensure microphone permissions (NSMicrophoneUsageDescription) are configured in Info.plist.
5. Build and run (Cmd + R).

## 📄 License
This project is created strictly for educational and personal research purposes. Feel free to explore, fork, and adapt the codebase!
