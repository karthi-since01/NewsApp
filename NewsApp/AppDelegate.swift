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

        let feedViewController = NewsFeedViewController()
        let navigationController = UINavigationController(rootViewController: feedViewController)
        navigationController.navigationBar.tintColor = .label

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

}
