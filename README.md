# Ladder

<p>
<a href="http://cocoadocs.org/docsets/Ladder"><img src="https://img.shields.io/cocoapods/v/Ladder.svg?style=flat"></a>
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://raw.githubusercontent.com/Limon-O-O/Ladder/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/Ladder.svg?style=flat"></a>
</p>

Checking app's version on the AppStore or Fir.im every particular time interval.

![version.png](https://raw.githubusercontent.com/Limon-O-O/Ladder/master/images/v.png)

## Requirements

iOS 8.0

Swift 2.0

## Usage

```swift
let appID = "333903271"
Ladder.interval = .Day // check update interval
Ladder.AppStore(appID: appID).check() { comparisonResult, releaseNotes in
}
```

## Installation

### CocoaPods

```ruby
pod 'Ladder', '~> 0.2'
```

### Carthage

```swift
github "Limon-O-O/Ladder"
```

## Contacts

Contact me on [Twitter](https://twitter.com/Limon______) or [Weibo](http://weibo.com/u/1783821582) . If you find an issue, just [open a ticket](https://github.com/Limon-O-O/Ladder/issues/new) on it. Pull requests are warmly welcome as well.

## License
Ladder is available under the MIT license. See the LICENSE file for more info.


