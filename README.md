# Voice Memos

A simple, privacy-first voice recorder for iOS and macOS with real‑time dBFS level visualizations, built with SwiftUI and AVFoundation.

## Overview

Voice Memos is a cross‑platform audio recording app focused on clarity and performance. It provides a clean SwiftUI interface with responsive charts that visualize decibel full-scale (dBFS) levels while recording and during playback. The app uses AVFoundation for system‑native recording and playback, and persists audio files directly to disk via FileManager—avoiding the overhead of a database.

## Features

- Real‑time dBFS visualization during recording and playback
- Native recording and playback powered by AVFoundation
- Microphone permission handling using AVAudioSession and system prompts
- On‑device file storage with FileManager (no database required)
- SwiftUI UI for a simple, cohesive experience on iOS and macOS
- Cross‑platform targets: iOS 18+ and macOS 15+

## Tech Stack
- Swift
- SwiftUI
- AVFoundation
- FileManager

## Requirements

- iOS 18+ and/or macOS 15+
- Xcode 26+ (or latest stable)
- Swift 6.2+

## Getting Started

- Clone the repository
- Build the app on your mac or iPhone

## Demo
*_Comming soon_*

## Future
This project is part of an ongoing effort to build apps that intersect with physics and mathematics world. Long‑term plans for this app, include adding audio filters, noise reduction, and other DSP‑oriented features to explore sound through a scientific lens.

