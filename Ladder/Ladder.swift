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
    case fir(appID: String, token: String)

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

    public func check(_ completion: @escaping (_ comparisonResult: ComparisonResult, _ releaseNotes: String?) -> Void) {

        guard needCheck else { return }

        switch self {

        case let .appStore(appID):

            let remote = "https://itunes.apple.com/cn/lookup?id=\(appID)"

            checkUpdate(from: remote) { comparisonResult, releaseNotes in
                DispatchQueue.main.async {
                    self.checkedDate = Date()
                    completion(comparisonResult, releaseNotes)
                }
            }

        case let .fir(appID, token):

            let remote = "https://api.fir.im/apps/latest/\(appID)?api_token=\(token)"

            checkUpdate(from: remote) { comparisonResult, releaseNotes in
                DispatchQueue.main.async {
                    self.checkedDate = Date()
                    completion(comparisonResult, releaseNotes)
                }
            }

        }
    }

    private func checkUpdate(from URLString: String, completion: @escaping (_ comparisonResult: ComparisonResult, _ releaseNotes: String?) -> Void) {

        guard let URL = URL(string: URLString) else { return }
        guard let localVersion = Bundle.main.ladder_localVersion else { return }

        let sessionConfiguration: URLSessionConfiguration = {
            $0.timeoutIntervalForRequest = 20
            return $0
        }(URLSessionConfiguration.default)

        let session = URLSession(configuration: sessionConfiguration)

        let task = session.dataTask(with: URL, completionHandler: { data, response, error in

            guard let unwrappedData = data else { return }

            guard let JSONDict = try? JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? NSDictionary else { return }

            var releaseNotes: String?
            var comparisonResult: ComparisonResult

            switch self {

            case .appStore:

                guard let infoDict = (JSONDict?["results"] as? [[String: AnyObject]])?.first else { return }

                guard let version = infoDict["version"] as? String else { return }

                comparisonResult = version.compare(localVersion)
                releaseNotes = infoDict["releaseNotes"] as? String

            case .fir:

                guard let version = JSONDict?["versionShort"] as? String else { return }

                comparisonResult = version.compare(localVersion)
                releaseNotes = JSONDict?["changelog"] as? String

                if comparisonResult == .orderedSame {

                    guard let build = JSONDict?["build"] as? String, let currentBuild = Bundle.main.ladder_localBuild else {
                        break
                    }

                    comparisonResult = build.compare(currentBuild)
                }
            }

            completion(comparisonResult, releaseNotes)
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

    fileprivate var needCheck: Bool {

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
