![NMEAParser logo](Resources/NMEAParserLogo.png)

[![Swift](https://img.shields.io/badge/Swift-5.9_5.10_6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.9_5.10_6.0-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_iPadOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS-Green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

## Features

- [x] Swift Concurrency Support Back to iOS 13 and macOS 10.15
- [x] Combine Support
- [x] Checksum Validation 
- [x] Descriptions for Fix Types
- [x] GGA Sentences
- [ ] RMC Sentences (coming!)
- [ ] GSV Sentences (coming!)

## Requirements

| Platform                                             | Minimum Swift Version | Installation                                                                                                         | Status                   |
| ---------------------------------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| iOS 13.0+ / macOS 10.15+ | 5.9 / Xcode 15.0      | [Swift Package Manager](#swift-package-manager) | Fully Tested             |



## Communication

- If you **find a bug**, open an issue here on GitHub and follow the guide. The more detail the better!

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding NMEAPArser as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/sindreoyen/NMEAParser.git", .upToNextMajor(from: "1.0.1"))
]
```

## Usage

### Configuring the Parser Instance

### Parsing NMEA Sentences

### Listening to Parsed Data

## Contributing

Before contributing to NMEAParser, please read the instructions detailed in the [contribution guide]().
