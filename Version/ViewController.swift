//
//  ViewController.swift
//  Version
//
//  Created by Limon on 2016/8/13.
//  Copyright © 2016年 Ladder. All rights reserved.
//

import UIKit
import Ladder

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let _ = Ladder.fir(appID: "", token: "")
        let _ = Ladder.bugly(appID: "", appKey: "", pid: 2, start: 0)

        let appID = "333903271"
        let appStore = Ladder.appStore(appID: appID)

        // Check update interval
        Ladder.interval = .none

        appStore.check() { comparisonResult, releaseNotes in

            guard comparisonResult == .orderedDescending else { return }

            let message = releaseNotes ?? "New Version!"

            let alert = UIAlertController(title: "Ladder", message: message, preferredStyle: .alert)

            let updateAction = UIAlertAction(title: "Update", style: .default, handler: {
                _ in

                if let URL = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)") {
                    UIApplication.shared.openURL(URL as URL)
                }

            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(updateAction)
            alert.addAction(cancelAction)

            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
        }

    }
}

