//
//  AppDelegate.swift
//  Vision Sample Project
//
//  Created by Jean Wallner on 04/11/2022.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let presenter = MainPresenter()
        let mainView = MainViewController(presenter: presenter)
        presenter.mainView = mainView
        window?.rootViewController = mainView
        window?.makeKeyAndVisible()

        return true
    }
}

