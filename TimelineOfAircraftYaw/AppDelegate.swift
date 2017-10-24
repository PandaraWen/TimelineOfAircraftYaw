//
//  AppDelegate.swift
//  TimelineOfAircraftYaw
//
//  Created by Pandara on 2017/10/23.
//  Copyright © 2017年 Pandara. All rights reserved.
//

import UIKit
import DJIDemoKit
import DJISDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var startViewCon: DDKStartViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.startViewCon = {
            let viewCon = DDKStartViewController()
            viewCon.delegate = self
            self.window?.rootViewController = viewCon
            return viewCon
        }()
        
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

private extension AppDelegate {
    func handleTimeLineEvent(_ event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) {
        if let error = error {
            ddkLogError("Error: \(error.localizedDescription), event: \(event.rawValue), info: \(String(describing: info))")
        } else {
            ddkLogInfo("event: \(event.rawValue), info: \(String(describing: info))")
        }
    }
    
    func goYawWithAngularVelocity(_ velocity: Double) {
        guard velocity < 100 && velocity > 0 else {
            return
        }
        
        var timelineElements = [DJIAircraftYawAction]()
        for _ in 0..<8 {
            let action = DJIAircraftYawAction(relativeAngle: 45, andAngularVelocity: velocity)!
            timelineElements.append(action)
        }
        
        if let error = DJISDKManager.missionControl()?.scheduleElements(timelineElements) {
            ddkLogError("Schedule element error: \(error.localizedDescription)")
            return
        }
        
        ddkLogInfo("Scheduled \(timelineElements.count) elements")
        
        DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event, element, error, info) in
            self.handleTimeLineEvent(event, element: element, error: error, info: info)
        })
        
        DJISDKManager.missionControl()?.startTimeline()
    }
}

extension AppDelegate: DDKStartViewControllerDelegate {
    func startViewControllerDidClickGoButton(_ viewCon: DDKStartViewController) {
        let actionSheet = UIAlertController(title: "Select an action", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Go yaw with angular velocity", style: .default, handler: { (action) in
            let alert = UIAlertController(title: "Set angular velocity", message: "within range [0, 100]", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                guard let str = alert.textFields![0].text, let velocity = Double(str) else {
                    return
                }
                
                self.goYawWithAngularVelocity(velocity)
            }))
            actionSheet.dismiss(animated: true, completion: nil)
            self.startViewCon.present(alert, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Stop and unschedule", style: .default, handler: { (action) in
            DJISDKManager.missionControl()?.stopTimeline()
            DJISDKManager.missionControl()?.unscheduleEverything()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.startViewCon.present(actionSheet, animated: true, completion: nil)
    }
}

