//
//  Ladder.swift
//  Version
//
//  Created by Limon on 2016/8/13.
//  Copyright © 2016年 Ladder. All rights reserved.
//

import Foundation

public enum Ladder {

    case AppStore(appID: String)
    case Fir(appID: String, token: String)

    public func check(completion: (comparisonResult: NSComparisonResult, releaseNotes: String?) -> Void) {

        switch self {

        case let .AppStore(appID):

            let remote = "https://itunes.apple.com/cn/lookup?id=\(appID)"

            checkUpdate(from: remote) { comparisonResult, releaseNotes in
                dispatch_async(dispatch_get_main_queue()) {
                    completion(comparisonResult: comparisonResult, releaseNotes: releaseNotes)
                }
            }

        case let .Fir(appID, token):

            let remote = "https://api.fir.im/apps/latest/\(appID)?api_token=\(token)"

            checkUpdate(from: remote) { comparisonResult, releaseNotes in
                dispatch_async(dispatch_get_main_queue()) {
                    completion(comparisonResult: comparisonResult, releaseNotes: releaseNotes)
                }
            }

        }
    }

    private func checkUpdate(from URLString: String, completion: (comparisonResult: NSComparisonResult, releaseNotes: String?) -> Void) {

        guard let URL = NSURL(string: URLString) else { return }
        guard let localVersion = NSBundle.mainBundle().ladder_localVersion else { return }

        let sessionConfiguration: NSURLSessionConfiguration = {
            $0.timeoutIntervalForRequest = 20
            return $0
        }(NSURLSessionConfiguration.defaultSessionConfiguration())

        let session = NSURLSession(configuration: sessionConfiguration)

        let task = session.dataTaskWithURL(URL) { data, response, error in

            guard let unwrappedData = data else { return }

            guard let JSONDict = try? NSJSONSerialization.JSONObjectWithData(unwrappedData, options: .MutableContainers) as? NSDictionary else { return }

            var releaseNotes: String?
            var comparisonResult: NSComparisonResult

            switch self {

            case .AppStore:

                guard let infoDict = (JSONDict?["results"] as? [[String: AnyObject]])?.first else { return }

                guard let version = infoDict["version"] as? String else { return }

                comparisonResult = version.compare(localVersion)
                releaseNotes = infoDict["releaseNotes"] as? String

            case .Fir:

                guard let version = JSONDict?["versionShort"] as? String else { return }

                comparisonResult = version.compare(localVersion)
                releaseNotes = JSONDict?["changelog"] as? String

                if comparisonResult == .OrderedSame {

                    guard let build = JSONDict?["build"] as? String, currentBuild = NSBundle.mainBundle().ladder_localBuild else {
                        break
                    }

                    comparisonResult = build.compare(currentBuild)
                }
            }

            completion(comparisonResult: comparisonResult, releaseNotes: releaseNotes)
        }
        
        task.resume()
    }
}

private extension NSBundle {
    
    var ladder_localBuild: String? {
        return objectForInfoDictionaryKey(String(kCFBundleVersionKey)) as? String
    }
    
    var ladder_localVersion: String? {
        return objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
    }
}
