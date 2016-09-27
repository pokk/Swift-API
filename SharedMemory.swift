//
//  SharedTantra.swift
//
//  Created by jieyi on 9/25/2016 AD.
//  Copyright © Jieyi. All rights reserved.
//


import Foundation

class SharedMemory {
    static let getInstance: SharedMemory = SharedMemory()

    public var timer:NSTimer?
    public var bgTask: BackgroundTaskManager?

    private init() {
    }
}
