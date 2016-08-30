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

        let _ = Ladder.Fir(appID: "", token: "")

        let appID = "333903271"
        let appStore = Ladder.AppStore(appID: appID)

        // Check update interval
        Ladder.interval = .None

        appStore.check() { comparisonResult, releaseNotes in

            guard comparisonResult == .OrderedDescending else { return }

            let message = releaseNotes ?? "New Version!"

            let alert = UIAlertController(title: "Ladder", message: message, preferredStyle: .Alert)

            let updateAction = UIAlertAction(title: "Update", style: .Default, handler: {
                _ in

                if let URL = NSURL(string: "itms-apps://itunes.apple.com/app/id\(appID)") {
                    UIApplication.sharedApplication().openURL(URL)
                }

            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addAction(updateAction)
            alert.addAction(cancelAction)

            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            
        }

    }
}

