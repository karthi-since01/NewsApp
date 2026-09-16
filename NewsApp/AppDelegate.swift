//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Karthi on 16/09/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = NewListViewController()
        let navigationController = UINavigationController(
            rootViewController: viewController
        )

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

}
