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

        let appStore = Ladder.AppStore(appID: "")

        appStore.check() { comparisonResult, releaseNotes in

            guard comparisonResult == .OrderedDescending else { return }

            let message = releaseNotes ?? "New Version!"

            let alert = UIAlertController(title: "Ladder", message: message, preferredStyle: .Alert)

            let updateAction = UIAlertAction(title: "Update", style: .Default, handler: {
                _ in
//                    UIApplication.sharedApplication().openURL("")
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addAction(updateAction)
            alert.addAction(cancelAction)

            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            
        }

    }
}

