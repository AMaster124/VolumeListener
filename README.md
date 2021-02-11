# VolumeListener

[![CI Status](https://img.shields.io/travis/AMaster124/VolumeListener.svg?style=flat)](https://travis-ci.org/AMaster124/VolumeListener)
[![Version](https://img.shields.io/cocoapods/v/VolumeListener.svg?style=flat)](https://cocoapods.org/pods/VolumeListener)
[![License](https://img.shields.io/cocoapods/l/VolumeListener.svg?style=flat)](https://cocoapods.org/pods/VolumeListener)
[![Platform](https://img.shields.io/cocoapods/p/VolumeListener.svg?style=flat)](https://cocoapods.org/pods/VolumeListener)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

VolumeListener is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VolumeListener', :git => 'https://github.com/AMaster124/VolumeListener.git'
```

## Capability
To get to the background modes capability list you:

1. Select the project from the Project navigator.
2. Click the app target.
3. Select the Capabilities tab.
4. Turn the Background Modes switch on.
5. Check the options: Audio, AirPlay, and Picture in Picture


## Usage

> [Example/VolumeListener/ViewController.swift](https://github.com/AMaster124/VolumeListener/blob/main/Example/VolumeListener/ViewController.swift)

Start volume listening

```swift
import VolumeListener

...

VolumeListener.sharedInstance().startListener(triggerCnt: 3, delegate: self)
```

Set listener status

```swift
VolumeListener.sharedInstance().setWait(wait: true)
```

Get listener status

```swift
VolumeListener.sharedInstance().isWait
```

## Author

AMaster124, bestfriend1990124@hotmail.com

## License

VolumeListener is available under the MIT license. See the LICENSE file for more info.
