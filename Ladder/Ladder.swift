//
//  Ladder.swift
//  Version
//
//  Created by Limon on 2016/8/13.
//  Copyright © 2016年 Ladder. All rights reserved.
//

import Foundation

public enum Ladder {

    case appStore(appID: String)
    case fir(urlString: String)
    case bugly(urlString: String)

    public enum Interval {
        case none
        case day
        case week
        case month
        case custom(minute: Int)

        var value: Int {
            switch self {
            case .none:
                return 0
            case .day:
                return 24 * 60
            case .week:
                return 24 * 60 * 7
            case .month:
                return 24 * 60 * 7 * 30
            case let .custom(minute):
                return max(minute, 0)
            }
        }
    }

    public static var interval: Interval = .none

    public func check(_ completion: @escaping (_ comparisonResult: ComparisonResult, _ releaseNotes: String?, _ info: [String: Any]?) -> Void) {

        switch self {

        case let .appStore(appID):

            let remote = "https://itunes.apple.com/cn/lookup?id=\(appID)"

            checkUpdate(from: remote) { comparisonResult, releaseNotes, info in
                DispatchQueue.main.async {
                    self.checkedDate = Date()
                    completion(comparisonResult, releaseNotes, info)
                }
            }

        case let .fir(urlString):

            checkUpdate(from: urlString) { comparisonResult, releaseNotes, info in
                DispatchQueue.main.async {
                    self.checkedDate = Date()
                    completion(comparisonResult, releaseNotes, info)
                }
            }

        case let .bugly(urlString):

            checkUpdate(from: urlString) { comparisonResult, releaseNotes, info in
                DispatchQueue.main.async {
                    self.checkedDate = Date()
                    completion(comparisonResult, releaseNotes, info)
                }
            }

        }
    }

    private func checkUpdate(from URLString: String, completion: @escaping (_ comparisonResult: ComparisonResult, _ releaseNotes: String?, _ info: [String: Any]?) -> Void) {

        guard let URL = URL(string: URLString) else { return }
        guard let localVersion = Bundle.main.ladder_localVersion else { return }

        let sessionConfiguration: URLSessionConfiguration = {
            $0.timeoutIntervalForRequest = 20
            return $0
        }(URLSessionConfiguration.default)

        let session = URLSession(configuration: sessionConfiguration)

        let task = session.dataTask(with: URL, completionHandler: { data, response, error in

            var info: [String: Any]?
            var releaseNotes: String?
            var comparisonResult: ComparisonResult = .orderedSame

            defer {
                session.finishTasksAndInvalidate()
                completion(comparisonResult, releaseNotes, info)
            }

            guard
                  let unwrappedData = data,
                  let jsonDictBuffer = try? JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [String: Any],
                  let jsonDict = jsonDictBuffer else {
                    return
            }

            switch self {

            case .appStore:

                guard let infoDict = (jsonDict["results"] as? [[String: AnyObject]])?.first else { return }

                guard let version = infoDict["version"] as? String else { return }

                info = infoDict
                comparisonResult = version.compare(localVersion)
                releaseNotes = infoDict["releaseNotes"] as? String

            case .fir:

                guard let version = jsonDict["versionShort"] as? String else { return }

                info = jsonDict
                comparisonResult = version.compare(localVersion)
                releaseNotes = jsonDict["changelog"] as? String

                if comparisonResult == .orderedSame {

                    guard
                        let buildString = jsonDict["build"] as? String,
                        let build = Int(buildString),
                        let localBuildString = Bundle.main.ladder_localBuild,
                        let localBuild = Int(localBuildString) else {
                            break
                    }

                    comparisonResult = build > localBuild ? .orderedDescending : .orderedAscending
                    if build == localBuild {
                        comparisonResult = .orderedSame
                    }
                }

            case .bugly:

                guard
                      let dataDict = jsonDict["data"] as? [String: Any],
                      let listBuffer = dataDict["list"] as? [[String: Any]] else {
                        return
                }


                let list = listBuffer.sorted() {

                    guard
                          let version1String = $0["version"] as? String,
                          let version1 = Int(version1String),
                          let version2String = $1["version"] as? String,
                          let version2 = Int(version2String) else {
                            return false
                    }

                    return version1 > version2
                }

                guard
                    let infoDict = list.first,
                    let buildString = infoDict["version"] as? String,
                    let build = Int(buildString),
                    let localBuildString = Bundle.main.ladder_localBuild,
                    let localBuild = Int(localBuildString) else {
                        return
                }

                info = infoDict
                comparisonResult = build > localBuild ? .orderedDescending : .orderedAscending
                if build == localBuild {
                    comparisonResult = .orderedSame
                }
                releaseNotes = infoDict["description"] as? String
            }
        }) 
        
        task.resume()
    }
}

extension Ladder {

    fileprivate var checkedDate: Date? {

        get {
            let timeInterval = (UserDefaults(suiteName: "top.limon.ladder")?.object(forKey: "checkedDateKey") as? Double) ?? 0.0
            return Date(timeIntervalSince1970: timeInterval)
        }

        nonmutating set {
            UserDefaults(suiteName: "top.limon.ladder")?.set(newValue?.timeIntervalSince1970 ?? 0.0, forKey: "checkedDateKey")
        }
    }

    public var needCheck: Bool {

        switch Ladder.interval {

        case .none:
            return true

        default:

            guard let unwrappedCheckedDate = checkedDate else { return true }

            func minutesBetweenDates(_ oldDate: Date, currentDate: Date) -> Int {
                let calendar = Calendar.current
                let components = (calendar as NSCalendar).components(.minute, from: oldDate, to: currentDate, options: .matchFirst)
                return components.minute ?? Int.max
            }

            let passedMinutes = minutesBetweenDates(unwrappedCheckedDate, currentDate: Date())
            return !(passedMinutes < Ladder.interval.value)
        }
    }

}

private extension Bundle {
    
    var ladder_localBuild: String? {
        return object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as? String
    }
    
    var ladder_localVersion: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
