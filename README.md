# ![CovertOpsData Logo](logo-covertops-data.png)


[![CI Status](https://img.shields.io/travis/patricklynch/CovertOpsData.svg?style=flat)](https://travis-ci.org/patricklynch/CovertOpsData)
[![Version](https://img.shields.io/cocoapods/v/CovertOpsData.svg?style=flat)](https://cocoapods.org/pods/CovertOpsData)
[![License](https://img.shields.io/cocoapods/l/CovertOpsData.svg?style=flat)](https://cocoapods.org/pods/CovertOpsData)
![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)
[![Platform](https://img.shields.io/cocoapods/p/CovertOpsData.svg?style=flat)](https://cocoapods.org/pods/CovertOpsData)
[![Language](https://img.shields.io/badge/swift-4.2-orange.svg)](https://developer.apple.com/swift)

`CovertOpsData` extension of the [`CovertOps`](https://github.com/patricklynch/CovertOps) framework that provides an easy, powerful and thread-safe implementation of a CoreData stack using operations to read and write from a persistent store.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.  The example app built within is a very simple "Todos" app that can fetch, create, delete and seach for todos loaded from [JSONPlaceholder(https://jsonplaceholder.typicode.com/). 

## Installation

To install using CocoaPods, add the following to your project Podfile:
```ruby
pod 'CovertOpsData'
```
To install using Carthage, add the following to your project Cartfile:
```ruby
github "patricklynch/CovertOpsData"
```

## Concepts

### Operations
As an extension to [`CovertOps`](https://github.com/patricklynch/CovertOps), this framework contains specialized operation subclasses that will read to and write from a CoreData persistent store while handling all of the treading rules for you.  There is also a handlful of extensions for `NSManagedObject` and `NSManagedObjectContext` that make it faster and easier to interact with the persistent store when you are implementing operations of your own.

## Author

Patrick Lynch: pdlynch@gmail.com

## License

CovertOpsData is available under the MIT license. See the LICENSE file for more info.
