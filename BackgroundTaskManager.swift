//
//  BackgroundTaskManager.swift
//
//  Created by jieyi on 9/25/2016 AD.
//  Copyright © Jieyi. All rights reserved.
//

import Foundation
import UIKit

class BackgroundTaskManager {
    static let getInstance: BackgroundTaskManager = BackgroundTaskManager()

    private var masterTaskId: UIBackgroundTaskIdentifier
    private var bgTaskIdList: [UIBackgroundTaskIdentifier]

    private init() {
        self.masterTaskId = UIBackgroundTaskInvalid
        self.bgTaskIdList = []
    }

    func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier {
        let application: UIApplication = UIApplication.sharedApplication()
        var bgTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

        if application.respondsToSelector(#selector(UIApplication.beginBackgroundTaskWithExpirationHandler(_:))) {
            bgTaskId = application.beginBackgroundTaskWithExpirationHandler({
                print("background task \(bgTaskId) expired...")
            })

            if self.masterTaskId == UIBackgroundTaskInvalid {
                self.masterTaskId = bgTaskId
                print("started master task \(self.masterTaskId)")
            }
            else {
                print("started background task \(bgTaskId)")
                self.bgTaskIdList.append(bgTaskId)
                self.endBackgroundTasks()
            }
        }

        return bgTaskId
    }

    @objc func endBackgroundTasks() -> Void {
        self.drainBGTaskList(false)
    }

    func endAllBackgroundTasks() -> Void {
        self.drainBGTaskList(true)
    }

    func drainBGTaskList(all: Bool) -> Void {
        let application: UIApplication = UIApplication.sharedApplication()
        let action = #selector(BackgroundTaskManager.endBackgroundTasks)

        if application.respondsToSelector(action) {
            for i in (0 ... self.bgTaskIdList.count) {
                let bgTaskId: UIBackgroundTaskIdentifier = self.bgTaskIdList[i]
                print("ending background task with id -\(bgTaskId)")

                application.endBackgroundTask(bgTaskId)
                self.bgTaskIdList.removeAtIndex(0)
            }

            if self.bgTaskIdList.count > 0 {
                print("kept background task id \(self.bgTaskIdList[0])")
            }

            if all {
                print("no more background tasks running...")
                application.endBackgroundTask(self.masterTaskId)
                self.masterTaskId = UIBackgroundTaskInvalid
            }
            else {
                print("kept background task id \(self.masterTaskId)")
            }
        }
    }
}
