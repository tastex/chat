//
//  ViewController.swift
//  Chat
//
//  Created by VB on 17.02.2021.
//

import UIKit
import OSLog

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        logEvent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logEvent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logEvent()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logEvent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logEvent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logEvent()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logEvent()
    }

    // MARK: - Logging

    func logEvent(_ method: String = #function) {
        os_log(.debug, log: .viewControllerLog,
               "Method call: %@", method)
    }
}

