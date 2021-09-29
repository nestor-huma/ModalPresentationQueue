//
//  AppDelegate.swift
//  ModalPresentationQueueExample
//
//  Created by Nestor on 6/26/16.
//  Copyright © 2016 Nestor. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIViewController.swizzleViewDidDisappear()
                return true
    }

}

