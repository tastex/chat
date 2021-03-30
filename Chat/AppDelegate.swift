//
//  AppDelegate.swift
//  Chat
//
//  Created by VB on 17.02.2021.
//

import UIKit
import OSLog
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coreDataStack = CoreDataStack()

    var state = "not running"

    func logStateChange(_ state: String, method: String = #function) {
        os_log(.debug, log: .appDelegateLog,
               "Application moved from \"%@\" to \"%@\": %@", self.state, state, method)
        self.state = state
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        coreDataStack.didUpdateDataBase = { stack in
            stack.printDatabaseStatistice()
        }
        coreDataStack.enableObservers()

        FirebaseApp.configure()
        let conversationsListVC = ConversationsListViewController(style: .grouped, coreDataStack: coreDataStack)
        let navigationVC = UINavigationController(rootViewController: conversationsListVC)
        navigationVC.navigationBar.prefersLargeTitles = true

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationVC
        self.window?.makeKeyAndVisible()

        logStateChange("inactive")

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        logStateChange("active")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        logStateChange("inactive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        logStateChange("background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        logStateChange("inactive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        logStateChange("not running")
    }
}

extension OSLog {
    #if ENABLE_LIFECYCLE_LOG
    static let appDelegateLog: OSLog = .init(subsystem: "ru.vladimir-bolotov.Chat", category: "AppDelegate Lifecycle")
    static let viewControllerLog: OSLog = .init(subsystem: "ru.vladimir-bolotov.Chat", category: "ViewController Lifecycle")
    #else
    static let appDelegateLog: OSLog = .disabled
    static let viewControllerLog: OSLog = .disabled
    #endif
}
